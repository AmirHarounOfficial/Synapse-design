#!/usr/bin/env sh
set -e

cd /var/www/html

# Ensure a .env exists and has an app key (the repo ships one; this is a safety net).
[ -f .env ] || cp .env.example .env
if ! grep -q "^APP_KEY=base64" .env; then
  php artisan key:generate --force --no-interaction
fi

# Upsert KEY=VALUE into .env. In this Laravel version the .env file overrides
# process env, so we must write the container's DB settings into .env directly.
set_env() {
  key="$1"
  val="$2"
  if grep -q "^${key}=" .env; then
    sed -i "s|^${key}=.*|${key}=${val}|" .env
  else
    echo "${key}=${val}" >> .env
  fi
}

set_env APP_ENV "${APP_ENV:-local}"
set_env APP_URL "${APP_URL:-http://localhost:8000}"
set_env DB_CONNECTION "${DB_CONNECTION:-mysql}"
set_env DB_HOST "${DB_HOST:-db}"
set_env DB_PORT "${DB_PORT:-3306}"
set_env DB_DATABASE "${DB_DATABASE:-schookeep}"
set_env DB_USERNAME "${DB_USERNAME:-schookeep}"
set_env DB_PASSWORD "${DB_PASSWORD:-secret}"
set_env SESSION_DRIVER "${SESSION_DRIVER:-database}"
set_env CACHE_STORE "${CACHE_STORE:-database}"
set_env QUEUE_CONNECTION "${QUEUE_CONNECTION:-database}"

# Drop any stale caches so the fresh .env is used.
php artisan config:clear >/dev/null 2>&1 || true

# Wait for the database to accept connections before migrating.
echo "Waiting for database ${DB_HOST}:${DB_PORT}..."
until php -r "exit((function(){try{new PDO('mysql:host='.getenv('DB_HOST').';port='.getenv('DB_PORT'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); return 0;}catch(Throwable \$e){return 1;}})());" 2>/dev/null; do
  sleep 2
done
echo "Database is up."

# Migrate + seed (idempotent seeders). Use --force in non-interactive container.
php artisan migrate --force --no-interaction
php artisan db:seed --force --no-interaction || true

# Public symlink so uploaded files (local 'public' disk) are served at /storage/...
php artisan storage:link >/dev/null 2>&1 || true

# Publish Log Viewer config & assets for deployment monitoring
php artisan vendor:publish --provider="Opcodes\LogViewer\LogViewerServiceProvider" --force >/dev/null 2>&1 || true
php artisan log-viewer:publish --force >/dev/null 2>&1 || true

echo "Starting SchooKeep API on :8000"
exec php artisan serve --host=0.0.0.0 --port=8000
