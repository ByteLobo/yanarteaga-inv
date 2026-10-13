#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"
command -v docker >/dev/null || { echo 'Instala Docker Engine y el plugin Compose. Ver docs/DESPLIEGUE-LINUX.md.' >&2; exit 1; }
docker compose version >/dev/null
docker info >/dev/null
mkdir -p deploy/backups
exec 9>deploy/.lock
flock -n 9 || { echo 'Hay otro despliegue o respaldo en curso.' >&2; exit 1; }
ENV="$ROOT/deploy/.env.production"
ACTION=${1:-help}
if [[ "$ACTION" == init ]]; then
  [[ ! -e "$ENV" ]] || { echo 'Ya existe la configuración; usa update.' >&2; exit 1; }
  URL=${2:-http://localhost:8088}
  [[ "$URL" =~ ^https://[a-zA-Z0-9.-]+$ || "$URL" == http://localhost:8088 ]] || { echo 'Usa https://tu.dominio o http://localhost:8088.' >&2; exit 1; }
  command -v openssl >/dev/null
  KEY=$(openssl rand -base64 32)
  PASS=$(openssl rand -hex 32)
  SECURE=false
  PROFILE=''
  [[ "$URL" == https://* ]] && SECURE=true && PROFILE=https
  printf 'APP_KEY=base64:%s\nDB_PASSWORD=%s\nAPP_URL=%s\nSITE_ADDRESS=%s\nSESSION_SECURE_COOKIE=%s\nCOMPOSE_PROFILES=%s\n' "$KEY" "$PASS" "$URL" "${URL#https://}" "$SECURE" "$PROFILE" > "$ENV"
fi
[[ -f "$ENV" ]] || { echo 'Primero ejecuta: bash deploy/linux.sh init https://tu.dominio' >&2; exit 1; }
APP_IMAGE=$(cat deploy/current-image 2>/dev/null || printf 'yanarteaga-inv:local')
export APP_IMAGE
DC=(docker compose --env-file "$ENV" -f deploy/compose.production.yaml)
artisan() { "${DC[@]}" exec -T --user www-data app php artisan "$@"; }
backup() {
  DEST="$ROOT/deploy/backups/$(date -u +%Y%m%dT%H%M%SZ)-$$"
  mkdir "$DEST"
  "${DC[@]}" exec -T db pg_dump -U yanarteaga -d yanarteaga -Fc > "$DEST/database.dump"
  "${DC[@]}" exec -T db pg_restore --list < "$DEST/database.dump" >/dev/null
  "${DC[@]}" exec -T app tar -C /var/www/html -czf - storage > "$DEST/storage.tar.gz"
  cp "$ENV" "$DEST/environment"
  printf '%s\n' "$APP_IMAGE" > "$DEST/image"
  git rev-parse HEAD > "$DEST/source-commit" 2>/dev/null || true
  (cd "$DEST" && sha256sum database.dump storage.tar.gz environment image > SHA256SUMS)
  echo "Respaldo: $DEST"
}
case "$ACTION" in
 init)
  "${DC[@]}" config --quiet
  "${DC[@]}" build app
  "${DC[@]}" up -d --wait db
  echo 'Configuración creada. Siguiente: bash deploy/linux.sh restore /ruta/sim_b.backup'
  ;;
 restore)
  FILE=${2:?Indica el archivo de respaldo}
  [[ -f "$FILE" ]] || { echo 'No existe el respaldo.' >&2; exit 1; }
  "${DC[@]}" up -d --wait db
  TABLES=$("${DC[@]}" exec -T db psql -U yanarteaga -d yanarteaga -Atc "select count(*) from pg_tables where schemaname not in ('pg_catalog','information_schema')")
  [[ "$TABLES" == 0 ]] || { echo 'La restauración inicial exige una base vacía. No se borraron datos.' >&2; exit 1; }
  "${DC[@]}" exec -T db pg_restore -U yanarteaga -d yanarteaga --no-owner --no-privileges --exit-on-error --single-transaction < "$FILE"
  "${DC[@]}" run --rm --no-deps app php artisan migrate --force
  "${DC[@]}" run --rm --no-deps app php artisan optimize
  "${DC[@]}" up -d --wait --wait-timeout 180
  echo 'Instalación disponible. Crea el gestionador con: bash deploy/linux.sh manager'
  ;;
 manager)
  "${DC[@]}" exec --user www-data app php artisan app:create-manager
  ;;
 backup)
  artisan down
  trap 'artisan up || true' EXIT
  backup
  artisan up
  trap - EXIT
  ;;
 update)
  [[ -d .git ]] || { echo 'Actualiza desde un clon Git del repositorio.' >&2; exit 1; }
  [[ -z $(git status --porcelain --untracked-files=no) ]] || { echo 'Hay cambios locales en archivos del proyecto; resuélvelos antes.' >&2; exit 1; }
  git fetch origin main
  git merge-base --is-ancestor HEAD origin/main || { echo 'El código local diverge de origin/main.' >&2; exit 1; }
  git merge --ff-only origin/main
  PREVIOUS_IMAGE="$APP_IMAGE"
  NEW_IMAGE="yanarteaga-inv:$(git rev-parse --short=12 HEAD)-$(date -u +%Y%m%dT%H%M%SZ)-$$"
  APP_IMAGE="$NEW_IMAGE" "${DC[@]}" build app
  artisan down
  trap 'artisan down || true; echo "Actualización interrumpida. Revisa los registros y la recuperación en docs/DESPLIEGUE-LINUX.md." >&2' ERR
  backup
  APP_IMAGE="$NEW_IMAGE"
  export APP_IMAGE
  "${DC[@]}" run --rm --no-deps app php artisan migrate --force
  "${DC[@]}" run --rm --no-deps app php artisan optimize
  "${DC[@]}" up -d --no-deps app
  artisan up
  "${DC[@]}" up -d --wait --wait-timeout 180
  printf '%s\n' "$APP_IMAGE" > deploy/current-image
  trap - ERR
  echo "Actualizado: $APP_IMAGE. Imagen previa: $PREVIOUS_IMAGE"
  ;;
 status)
  "${DC[@]}" ps
  curl --fail --silent --show-error http://127.0.0.1:8088/ready
  ;;
 logs) "${DC[@]}" logs --tail=100 "${2:-app}" ;;
 *) echo 'Uso: bash deploy/linux.sh {init [URL]|restore BACKUP|manager|backup|update|status|logs [SERVICIO]}' ;;
esac
