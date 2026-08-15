# SchooKeep Backend (Laravel 12 API)

REST API for the SchooKeep UAE school-health app. Token auth via Laravel Sanctum, role-based access
control, SQLite for local dev. The authoritative data model + endpoint list is in [DOMAIN_SCHEMA.md](DOMAIN_SCHEMA.md).

## Run with Docker (recommended)

Requires Docker Desktop running.

```bash
cd backend
docker compose up --build        # API → http://localhost:8000  (MySQL on host port 3307)
```

The `app` container waits for MySQL, runs migrations + seeders automatically, then serves the API on
:8000. Data persists in the `schookeep_db` volume. Stop with `docker compose down` (add `-v` to also
wipe the database volume). Code changes require a rebuild (`docker compose up --build`).

## Run locally (without Docker)

```bash
cd backend
composer install                 # if vendor/ is missing
php artisan migrate:fresh --seed # build schema + demo data (uses SQLite by default)
php artisan serve                # http://127.0.0.1:8000
```

The Flutter app defaults to `http://127.0.0.1:8000/api` (override with
`flutter run --dart-define=API_BASE_URL=http://<host>:8000/api`). Either run option serves on :8000,
so the app connects the same way.

## Demo accounts

One user per role, all with password **`password`** (school: *Al Noor International School*):

| Role | Email |
|---|---|
| Nurse | `nurse@schookeep.ae` |
| Parent | `parent@schookeep.ae` |
| Teacher | `teacher@schookeep.ae` |
| Cafeteria | `cafeteria@schookeep.ae` |
| Security | `security@schookeep.ae` |
| Bus driver | `bus@schookeep.ae` |
| Counselor | `counselor@schookeep.ae` |
| Secretary | `secretary@schookeep.ae` |
| Principal | `principal@schookeep.ae` |
| Physician | `physician@schookeep.ae` |
| Vice Principal | `vp@schookeep.ae` |
| Admin | `admin@schookeep.ae` |

## Auth

```
POST /api/auth/login   {email, password}  -> {token, user}
GET  /api/auth/me       (Bearer token)     -> {user}
POST /api/auth/logout   (Bearer token)
```

All other `/api/*` routes require `Authorization: Bearer <token>`. Role-restricted routes return 403
for the wrong role (admin always passes). ~61 routes across these clusters: students, medications &
dose administrations, clinic visits / emergency consents / documents, cafeteria (meals, halal certs,
alerts), pickups & bus, counselor tags/reports, notifications, audit logs, weather advisories.

## Structure

- `app/Enums/Role.php` — the 12 roles. `app/Http/Middleware/EnsureUserRole.php` — `role:` guard.
- `app/Models/*`, `app/Http/Controllers/Api/*`, `app/Http/Resources/*` — one per entity.
- `routes/api.php` → auth + `require routes/domain.php`, which auto-includes every
  `routes/clusters/*.php` (each domain cluster registers its own routes there).
- `database/migrations/2026_06_23_*` — schema. `database/seeders/*Seeder.php` — demo data per cluster.

## Notes / next steps

- Dev uses SQLite (`database/database.sqlite`). For production set `DB_*` in `.env` to MySQL/Postgres.
- File uploads (documents, photos, signatures) currently store URLs/paths only — wire `storage` + a
  disk when implementing real uploads.
- The Flutter app's data layer (`flutter_app/lib/core/network/api_client.dart`,
  `features/auth/data/auth_repository.dart`) is wired for **auth** end-to-end; other features still use
  inline mock data. Add a repository per feature following the same pattern to connect the rest.
