# yanarteaga · Gestión de inventario

Aplicación Laravel 12 + React 19 + PostgreSQL 16 construida a partir de `MSIBO.xpz` y `sim_b.backup`. Interfaz en español, identificación textual genérica y sin logos. El gestionador inicial es `yanarteaga`.

## Despliegue en Ubuntu / Kali Linux

Consulta [la guía de despliegue Linux](docs/DESPLIEGUE-LINUX.md). Incluye instalación, HTTPS, restauración inicial y actualización con respaldo. Comienza con `bash deploy/linux.sh init https://tu.dominio`.

## Empezar en esta computadora

La carpeta contiene una instalación con dependencias y una copia aislada de la base del respaldo. Desde la carpeta `outputs`, ejecuta:

```powershell
.\Iniciar-app.ps1
```

Abre `http://127.0.0.1:8088`. El usuario y la contraseña temporal están en `ACCESO-LOCAL.md`. Para detener el entorno:

```powershell
.\Detener-app.ps1
```

Los scripts usan el PHP portátil en `../work/php`, la instancia en `../work/pgdata` y PostgreSQL 16 instalado en esta computadora. La base usa el puerto 55433 y solo escucha en loopback. El servidor PHP usa el puerto 8088. Estos scripts no configuran servicios permanentes.

`Vista-previa.html` se abre directamente en un navegador de escritorio. Es una muestra de solo lectura de los datos recuperados, con hasta 25 registros por pantalla, y no permite guardar, aprobar, exportar ni consultar todos los detalles. La aplicación Laravel ofrece las operaciones completas.

## Funciones implementadas

- Inicio de sesión, sesiones de servidor, protección CSRF y límite de intentos de acceso.
- Tablero con valor neto del inventario, pendientes, alertas y actividad mensual.
- Existencias por producto, lote, almacén y financiamiento; filtros, paginación y CSV.
- Ingresos y salidas: borrador → elaborado → aprobado, numeración y auditoría.
- Ajustes de cantidades positivos y negativos referenciados al lote de ingreso.
- Transferencias con aprobación en origen y recepción única en destino; conservación de lote, vencimiento, costo y financiamiento.
- Solicitud y autorización/rechazo de anulación; reversión de movimientos sin borrar documentos.
- Kardex apoyado en la vista original de movimientos aprobados.
- Centro de reportes con PDF, Excel e impresión: documentos de ingreso/salida/ajuste, kardex valorado, saldos mensuales, vencimientos, inventario físico, resumen de costos y listados.
- Registro de elaboración/aprobación y emisiones con huella SHA-256.
- Apertura/cierre de períodos y reconstrucción del resumen mensual al cerrar.
- Inventario físico con bloqueo de productos durante el conteo y ajustes de las diferencias al concluir.
- Planificación de compras con mínimo, máximo, fecha estimada de ruptura y pedido sugerido.
- Registro de activos fijos y asignación de custodia, con historial de asignaciones.
- Mantenimiento de productos, almacenes, proveedores, personas, oficinas, familias, grupos, categorías, centros de costo, cargos, asignaciones y rangos.
- Habilitación y configuración de productos por almacén.
- Usuarios con roles administrador, gestionador, operador y consulta; alcance por almacén.
- Consulta de los conteos y planes del sistema original, junto con los nuevos registros.

## Instalar en otro servidor

Requisitos: PHP 8.4 o superior compatible con las dependencias bloqueadas, Composer, Node 22, PostgreSQL 16. La instalación verificada usó PHP 8.4.26, Laravel 12.70.0, React 19 y Vite 7.3.7. Activa `pdo_pgsql`, `mbstring`, `openssl`, `fileinfo`, `zip` e `intl`.

1. Extrae `yanarteaga-app.zip` y entra en la carpeta `yanarteaga`.
2. Instala las dependencias y configura `.env`:

```powershell
composer install
Copy-Item .env.example .env
php artisan key:generate
```

Configura la conexión PostgreSQL con una base nueva, un usuario propio y su contraseña. No uses la base de producción para la instalación inicial.

3. Restaura el respaldo en esa base nueva, conservando el esquema `msib`:

```powershell
createdb -h 127.0.0.1 -U tu_usuario yanarteaga
pg_restore -h 127.0.0.1 -U tu_usuario -d yanarteaga --no-owner --no-privileges --exit-on-error "C:/Users/daniel.arteaga/Downloads/sim_b.backup"
```

El respaldo original se mantiene separado del ZIP. `database/legacy/schema-original.sql` contiene el esquema extraído sin filas ni contraseñas. Se incluye para referencia; la aplicación con los datos originales requiere restaurar el backup.

4. Ejecuta las migraciones de la nueva aplicación y crea el gestionador:

```powershell
php artisan migrate
php artisan app:create-manager
```

El segundo comando solicita una contraseña de al menos 12 caracteres. No reutiliza las contraseñas de GeneXus/GAM. Si ya existe `yanarteaga`, el comando se detiene sin cambiar su contraseña.

5. Compila la interfaz y arranca:

```powershell
npm ci
npm run build
php artisan serve --host=127.0.0.1 --port=8088
```

Para desarrollo, `npm run dev` sirve los recursos con Vite y `composer dev` arranca Laravel. Para producción, el directorio público es `public/`; configura HTTPS, `APP_ENV=production`, `APP_DEBUG=false`, `SESSION_SECURE_COOKIE=true` y una clave propia. No sirvas la raíz del proyecto.

## Docker opcional

Se incluyen Dockerfile, Apache y Compose. Para producción en Ubuntu/Kali usa deploy/compose.production.yaml y la guía Linux. La compilación, el arranque, las migraciones, el respaldo y la actualización de ese entorno pasaron en GitHub Actions sobre Ubuntu 24.04. La variante compose.yaml siguiente es para uso local.

Configura `.env` con `DB_PASSWORD` y `APP_KEY`, luego:

```powershell
docker compose up -d --build
docker compose cp "C:/Users/daniel.arteaga/Downloads/sim_b.backup" db:/tmp/sim_b.backup
docker compose exec db pg_restore -U yanarteaga -d yanarteaga --no-owner --no-privileges --exit-on-error /tmp/sim_b.backup
docker compose exec app php artisan migrate --force
docker compose exec app php artisan app:create-manager
```

Acceso: `http://127.0.0.1:8088`. PostgreSQL no publica un puerto del host. Los datos persisten en el volumen `postgres_data`. El arranque no restaura ni modifica automáticamente el respaldo.

## Verificación

Las suites de inventario, reportería y disponibilidad pasaron: **24 pruebas y 1.686 comprobaciones**. La suite `tests/Feature/InventoryWorkflowTest.php` se ejecutó sobre la copia restaurada de PostgreSQL. Cada prueba usa una transacción que se revierte al terminar. Incluye consultas de los módulos, stock, impuestos, estados, fechas, financiamiento, transferencias, anulaciones, ajustes, conteos, permisos, activos y planificación.

Para repetirla, usa una copia de prueba del respaldo, ejecuta las migraciones y crea `yanarteaga`. Configura la conexión en `.env`; `phpunit.xml` usa PostgreSQL y la base `yanarteaga`.

```powershell
php artisan test
```

La compilación de React y los PDF de muestra están verificados; los PDF se renderizaron y revisaron visualmente. La revisión de la interfaz en navegador quedó sin verificar: el entorno aislado no permitió acceder al servidor loopback y su navegador bloqueó archivos `file://`. El despliegue de producción Docker se verificó en Ubuntu 24.04 mediante GitHub Actions; Kali no se ejecutó en una máquina de prueba.

## Alcance de la migración

Esta es una nueva implementación funcional de los módulos descritos, no una conversión automática de todos los objetos del XPZ ni una réplica exacta de las pantallas WorkWithPlus. La matriz `docs/REGLAS-DE-NEGOCIO.md` distingue reglas recuperadas, diferencias entre archivos y decisiones de esta implementación.

Las integraciones externas de CRS, correo, mensajería, API/GAM, repositorio digital, importación Excel y circuito completo de actas de activos no se migraron. Los informes de almacén y sus exportaciones se implementaron; véase `docs/REPORTERIA.md`. Sus datos se conservan en el esquema restaurado y no se activan llamadas a servicios externos. Los nuevos conteos, planes y asignaciones usan tablas `app_*`, con consulta separada de su historial original.

El esquema anterior conserva los identificadores y documentos. La nueva autorización usa `public.users`, roles y almacenes asignados; no importa automáticamente usuarios ni permisos de GAM. La auditoría `app_audit` corresponde a las acciones realizadas en esta aplicación.

Referencias de implementación: [Laravel](https://laravel.com/docs/12.x), [React](https://react.dev/learn/build-a-react-app-from-scratch), [Vite](https://vite.dev/guide/), [pg_restore](https://www.postgresql.org/docs/16/app-pgrestore.html).


## Documentación y reportería

La guía de formularios, filtros, cálculos, firmas, emisiones y correspondencia con el XPZ está en [docs/REPORTERIA.md](docs/REPORTERIA.md). Los cambios de este módulo se aplican con `composer install`, `php artisan migrate`, `npm ci` y `npm run build`. En esta copia ya se aplicaron.
