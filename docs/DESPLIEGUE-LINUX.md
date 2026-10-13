# Despliegue y actualización en Ubuntu / Kali Linux

El despliegue usa Docker Engine y Compose v2: PHP 8.4, Apache, Node 22 durante compilación, PostgreSQL 16 y Caddy 2 para HTTPS. Así se mantienen las mismas dependencias en ambas distribuciones. No instala PHP ni Node en el host. El repositorio es https://github.com/ByteLobo/yanarteaga-inv.

## Preparar Linux

Recomendación operativa: servidor Ubuntu LTS con al menos 2 núcleos, 4 GB de RAM y espacio para la base más dos respaldos. Kali también puede ejecutar este despliegue. Las instrucciones de Docker para Kali usan el repositorio Debian; no uses el repositorio Ubuntu en Kali.

Instala Git, curl, openssl y util-linux (flock):

```bash
sudo apt update
sudo apt install -y git curl openssl util-linux ca-certificates
```

Instala Docker Engine y el plugin Compose v2 siguiendo la guía oficial de tu distribución:

- Ubuntu: https://docs.docker.com/engine/install/ubuntu/
- Kali: https://www.kali.org/docs/containers/installing-docker-on-kali/
- Debian / derivados: https://docs.docker.com/engine/install/debian/

Activa el servicio y verifica:

```bash
sudo systemctl enable --now docker
sudo docker version
sudo docker compose version
```

Los ejemplos siguientes se ejecutan con un usuario que tiene acceso a Docker. Si tu usuario no lo tiene, ejecuta el script con sudo y conserva esa misma forma para instalación, respaldo y actualización. El acceso al socket de Docker permite administrar el host.

## Instalación inicial con el respaldo original

```bash
git clone https://github.com/ByteLobo/yanarteaga-inv.git
cd yanarteaga-inv
bash deploy/linux.sh init https://inventario.tu-dominio.com
bash deploy/linux.sh restore /ruta/privada/sim_b.backup
bash deploy/linux.sh manager
bash deploy/linux.sh status
```

Sustituye el dominio por el tuyo antes de ejecutar init. DNS debe apuntar al servidor y los puertos TCP 80/443 deben estar disponibles. Caddy obtiene y renueva certificados automáticamente. PostgreSQL no publica puerto; Apache solo se publica en 127.0.0.1:8088. El navegador accede al dominio HTTPS. El proxy conserva la información HTTPS para Laravel; las cookies de sesión son seguras.

`init` genera APP_KEY y contraseña de PostgreSQL aleatorias en `deploy/.env.production`, con permisos 600. No las cambia en una actualización. Guarda esa configuración de forma privada; cambiar APP_KEY invalida las sesiones y cualquier dato cifrado con esa clave. No edites DB_PASSWORD sin cambiar también la contraseña del usuario PostgreSQL: el contenedor solo aplica POSTGRES_PASSWORD al crear el volumen por primera vez.

`restore` solo acepta una base sin tablas de usuario. Ejecuta pg_restore en una transacción, sin borrar una instalación existente; aplica migraciones e inicia el servicio. `manager` solicita la contraseña del gestionador de forma interactiva. El respaldo debe copiarse al servidor por un canal privado y nunca colocarse dentro del repositorio público. También puedes iniciar con el esquema vacío en un entorno de prueba, mediante el procedimiento de CI, pero no recuperarás los catálogos y datos del respaldo.

## Prueba local en Linux, sin dominio

```bash
bash deploy/linux.sh init http://localhost:8088
bash deploy/linux.sh restore /ruta/privada/sim_b.backup
bash deploy/linux.sh manager
```

Abre http://localhost:8088 desde ese equipo. Para un servidor remoto usa un túnel SSH: `ssh -L 8088:127.0.0.1:8088 usuario@servidor`. Este modo no activa Caddy y usa cookies sin Secure únicamente para HTTP local. Para pasar luego a HTTPS cambia APP_URL, SITE_ADDRESS, SESSION_SECURE_COOKIE=true y COMPOSE_PROFILES=https en el archivo privado, y ejecuta `bash deploy/linux.sh update`.

## Actualizar una instalación

```bash
cd /ruta/yanarteaga-inv
bash deploy/linux.sh update
bash deploy/linux.sh status
```

El script exige un clon Git sin modificaciones en archivos versionados. Descarga main y permite solo avance directo, compila la imagen etiquetada por commit antes de interrumpir el servicio, activa mantenimiento, respalda base/archivos/configuración, ejecuta migraciones, renueva los contenedores y verifica disponibilidad. No cambia usuarios, contraseñas, claves ni volúmenes. No ejecuta migrate:fresh ni elimina volúmenes. El mantenimiento también bloquea cambios de inventario durante la copia.

No se cambian las versiones mayores de PostgreSQL automáticamente. Una actualización mayor de PostgreSQL necesita un procedimiento de migración propio. El script usa etiquetas mayores de imágenes; las versiones exactas se registran en el entorno Docker y conviene fijar digests en una operación que exija reproducibilidad estricta.

Las actualizaciones futuras de los propios scripts se usan en la siguiente ejecución. Si cambian las instrucciones de despliegue, lee esta guía antes de actualizar.

## Respaldos y observación

```bash
bash deploy/linux.sh backup
bash deploy/linux.sh logs app
bash deploy/linux.sh logs db
bash deploy/linux.sh status
```

Los respaldos se guardan en `deploy/backups/FECHA-IDENTIFICADOR/`: database.dump, storage.tar.gz, environment, image, source-commit y SHA256SUMS. Contienen información privada y la clave de la aplicación. El directorio tiene permisos restringidos, está excluido de Git y de la imagen. Copia respaldos cifrados fuera del servidor y define retención según tu operación; no se elimina ninguno automáticamente. No los sirvas por HTTP.

`/up` comprueba que Laravel inicia. `/ready` responde 200 solo con clave configurada, interfaz compilada, conexión disponible y tablas de inventario/reportes existentes; devuelve 503 sin detalles internos si falla. No sustituye una prueba funcional de todas las operaciones. Los reinicios usan restart: unless-stopped; un contenedor unhealthy no se reinicia por ese estado por sí solo, así que revisa registros si status falla.

## Recuperación de una actualización fallida

El script intenta mantener el servicio en mantenimiento. No revierte migraciones automáticamente, porque una reversión parcial podría perder datos. Primero revisa logs y el último respaldo. Si la migración aplicada es compatible con la versión anterior, usa su imagen registrada en el respaldo:

```bash
export APP_IMAGE=$(cat deploy/backups/RESPALDO/image)
docker compose --env-file deploy/.env.production -f deploy/compose.production.yaml up -d --no-deps app
docker compose --env-file deploy/.env.production -f deploy/compose.production.yaml exec --user www-data app php artisan up
docker compose --env-file deploy/.env.production -f deploy/compose.production.yaml up -d --wait --wait-timeout 180
printf '%s\n' "$APP_IMAGE" > deploy/current-image
```

Reemplaza RESPALDO por el directorio real. Si las migraciones no son compatibles, conserva la instalación fallida y restaura el dump en una base/volumen nuevos, con la imagen del respaldo y su configuración; restaura también storage.tar.gz. Verifica los SHA256SUMS y prueba esa restauración antes de sustituir el servicio. No uses `down -v` sobre la instalación con datos. La recuperación completa requiere decidir qué cambios posteriores al respaldo se pueden conservar.

## Verificación del paquete

Se incluye `.github/workflows/linux-deploy.yml`, que valida Bash, ShellCheck y Compose, compila la imagen y prueba migraciones y `/ready` con el esquema original sin datos personales en Ubuntu. No despliega en un servidor ni crea credenciales reales. En la computadora Windows de preparación no hay Docker ni WSL instalado: la ejecución real del contenedor y los scripts se verifica en ese workflow y en tu servidor Linux.

Guía de HTTPS: https://caddyserver.com/docs/automatic-https
