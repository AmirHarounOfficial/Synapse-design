# SchooKeep Backend — Domain Schema & API Spec (authoritative contract)

Laravel 12 + Sanctum (token auth) + SQLite (dev). All API routes are prefixed `/api` and (except auth
login) protected by `auth:sanctum`. Responses use Eloquent API Resources. Roles are enforced with a
`role:` middleware. Money/dates: dates `Y-m-d`, datetimes ISO-8601.

## Conventions
- Every table has `id` (bigint, auto) + `created_at`/`updated_at` unless noted.
- Foreign keys: `<entity>_id`, `constrained()->cascadeOnDelete()` unless the relation is optional
  (then `nullOnDelete()` + nullable).
- Bilingual text fields: a base column (English) plus a `*_ar` nullable column (Arabic), e.g. `name`,
  `name_ar`. Status fields are `string` columns with documented enum values (kept as strings for SQLite).
- Model files: `app/Models/<Name>.php`. Controllers: `app/Http/Controllers/Api/<Name>Controller.php`.
  Resources: `app/Http/Resources/<Name>Resource.php`. Seeders: `database/seeders/<Name>Seeder.php`.

## Roles (enum, on `users.role`)
`nurse, parent, teacher, cafeteria, security, bus_driver, counselor, secretary, principal, physician,
vice_principal, admin`

## Tables

### schools
name, name_ar, emirate, curriculum, license_authority, code (unique invitation code), address,
phone, logo_url, ramadan_mode (bool, default false).

### users  (extends Laravel default users table via a follow-up migration)
ADD: role (string), school_id (nullable FK schools), name_ar (nullable), phone (nullable),
title (nullable), avatar_url (nullable), license_number (nullable), license_authority (nullable),
license_expiry (date nullable), is_active (bool default true), locale (string default 'en').
Keep default: name, email (unique), password. User model uses HasApiTokens.

### students
school_id FK, name, name_ar, grade, section, emirates_id (nullable, unique), date_of_birth (date),
gender (nullable), photo_url (nullable), blood_type (nullable), curriculum (nullable),
medical_summary (text nullable), profile_active (bool default true).

### student_guardian  (pivot: parent users ↔ students)
student_id FK, user_id FK (a parent), relationship (string), is_primary (bool), can_pickup (bool).
Unique (student_id, user_id).

### authorized_persons  (pickup authorization)
student_id FK, name, relationship, phone, emirates_id (nullable), photo_url (nullable),
qr_token (string, unique), is_active (bool default true).

### medications
student_id FK, name, name_ar (nullable), dosage, route (nullable), instructions (text nullable),
status (pending|approved|active|declined|suspended), prescribed_by (nullable), requires_physician (bool),
approved_by (nullable FK users physician), approved_at (datetime nullable),
supply_count (int nullable), low_supply_threshold (int nullable), start_date (date nullable),
end_date (date nullable), is_halal_sensitive (bool default false).

### medication_doses  (schedule rows)
medication_id FK, scheduled_time (time), days_of_week (json — e.g. ["mon","tue"]), label (nullable).

### dose_administrations  (the log)
medication_id FK, student_id FK, administered_by (nullable FK users nurse),
scheduled_for (datetime nullable), administered_at (datetime nullable),
status (given|missed|refused|conflict|pending), notes (text nullable).

### clinic_visits
student_id FK, school_id FK, nurse_id (nullable FK users), reason, reason_ar (nullable),
notes (text nullable), severity (low|medium|high|critical), is_emergency (bool default false),
visited_at (datetime), outcome (nullable), photo_url (nullable).

### emergency_consents
student_id FK, clinic_visit_id (nullable FK), requested_by (nullable FK users),
parent_id (nullable FK users), status (pending|approved|declined), details (text nullable),
responded_at (datetime nullable).

### documents
student_id FK, type (string — e.g. insurance_card, vaccination, consent, medical_report),
title, file_path (nullable), status (pending|approved|rejected), expiry_date (date nullable),
uploaded_by (nullable FK users), reviewed_by (nullable FK users), reviewed_at (datetime nullable),
notes (text nullable).

### student_allergens
student_id FK, allergen, allergen_ar (nullable), severity (mild|moderate|severe|life_threatening),
notes (nullable).

### meals
school_id FK, name, name_ar (nullable), date (date), is_halal (bool default true),
halal_certified (bool default false), allergens (json nullable).

### halal_certifications
school_id FK, supplier (string), certificate_no (string), issued_date (date), expiry_date (date),
status (valid|expiring|expired).

### cafeteria_alerts
school_id FK, student_id (nullable FK), created_by (nullable FK users), title, message (text),
severity (info|warning|critical), is_halal_issue (bool default false), acknowledged (bool default false),
created_for_date (date nullable).

### pickups
student_id FK, authorized_person_id (nullable FK), security_guard_id (nullable FK users),
method (qr|manual), status (pending|verified|released|denied), released_at (datetime nullable),
notes (nullable).

### bus_routes
school_id FK, name, driver_id (nullable FK users), bus_number (nullable), period (morning|afternoon),
status (scheduled|in_progress|completed).

### bus_boarding_events
bus_route_id FK, student_id FK, type (boarding|deboarding), status (boarded|deboarded|absent|pending),
occurred_at (datetime nullable), parent_notified (bool default false), stop_name (nullable).

### counselor_tags  (confidential)
student_id FK, counselor_id (nullable FK users), tags (json — psychosocial tags), notes (text nullable),
context (nullable), tagged_at (datetime).

### counselor_reports  (confidential)
student_id (nullable FK), counselor_id (nullable FK users), type (string), period (nullable),
status (draft|generated|submitted), submitted_to_parent (bool default false), generated_at (datetime nullable),
content (json nullable).

### app_notifications
user_id FK (recipient), type (string), title, body (text), data (json nullable),
read_at (datetime nullable).

### audit_logs
user_id (nullable FK users), action (string), entity_type (nullable), entity_id (nullable),
meta (json nullable), ip (nullable). Has created_at (no updated_at).

### weather_advisories
school_id (nullable FK), kind (haboob|heat|rain|fog), severity (advisory|warning|severe),
message, message_ar (nullable), active (bool default true), starts_at (datetime nullable),
ends_at (datetime nullable).

## API endpoints (all under /api)

Auth (public): `POST /auth/login` {email,password} → {token, user}. (Demo: any seeded user, password `password`.)
Authed: `POST /auth/logout`, `GET /auth/me` → current user (+school).

REST resources (use `Route::apiResource`, plural kebab where multiword). Index supports query filters
in brackets:
- `students` (filter: ?grade, ?q search name/eid, ?school_id) — all staff roles read; secretary/principal write.
- `students/{student}/medications`, `medications` (filter ?status), `medications/{m}` show/update;
  `POST medications/{m}/approve` & `/decline` (physician only).
- `dose-administrations` (filter ?date, ?student_id) + `POST` to log a dose (nurse).
- `clinic-visits` (filter ?date, ?student_id) CRUD (nurse).
- `emergency-consents` index/show/`POST {id}/respond` {status} (parent).
- `documents` (filter ?status) index/show/`POST {id}/review` {status} (nurse).
- `authorized-persons` (by student) CRUD (parent); `POST pickups/scan` {qr_token} (security).
- `pickups` index + `POST {id}/release` (security).
- `meals` (?date), `halal-certifications`, `cafeteria-alerts` CRUD (cafeteria/nurse).
- `bus-routes` (driver), `bus-routes/{r}/events` `POST` board/deboard.
- `counselor-tags`, `counselor-reports` (counselor only — confidential).
- `notifications` index + `POST {id}/read`.
- `weather-advisories` index (all) + CRUD (principal).
- `audit-logs` index (principal/admin only).
- `schools/{school}` show/update (principal); `POST /parent/onboarding/verify-code` {code} (public-ish).

RBAC: apply `->middleware('role:nurse,physician,...')` per route group. Read endpoints generally allow
all authenticated staff; writes are role-scoped as noted.
