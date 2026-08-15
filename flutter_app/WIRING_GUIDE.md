# SchooKeep — API Wiring Guide (per-domain)

You are replacing a screen's **inline mock data** with **live calls to the Laravel API**, keeping the
existing pixel-faithful UI intact. Flutter app: `D:\work\Synapse Health App\flutter_app`. Backend:
`D:\work\Synapse Health App\backend` (running at `http://127.0.0.1:8000/api`; demo logins
`<role>@schookeep.ae` / `password`).

## Read these first (the reference implementation — copy this pattern exactly)
- `lib/core/network/api_client.dart` — Dio wrapper (bearer token auto-attached). Get it via `sl<ApiClient>()`.
- `lib/core/network/data_state.dart` — `DataState<T>` = `DataLoading | DataLoaded(data) | DataError(message)`.
- `lib/core/network/paginated.dart` — `Paginated<T>.fromJson(json, T.fromJson)` for Laravel `paginate()`.
- `lib/data/models/student.dart` — model `fromJson` pattern.
- `lib/data/repositories/student_repository.dart` — repository pattern + `messageFor(e)` error mapper.
- `lib/features/nurse/cubit/student_list_cubit.dart` — Cubit pattern (`Cubit<DataState<T>>`, `load()`).
- `lib/features/nurse/view/student_search_screen.dart` — screen wired with BlocProvider + BlocBuilder +
  loading/error(retry)/empty states.
- `lib/features/auth/data/auth_repository.dart` — auth + error-message mapping.

## API response envelopes (Laravel API Resources)
- Single resource → `{ "data": { ... } }`  → parse `res.data['data']`.
- Paginated collection → `{ "data": [...], "meta": { current_page, last_page, total } }` → use `Paginated.fromJson`.
- Non-paginated collection → `{ "data": [...] }` → map `res.data['data'] as List`.
- Errors: 422 validation → `res.data['errors']` (map of field→[messages]); 401 expired; 403 forbidden.

## Hard rules
1. **Do NOT add dependencies.** `flutter_map`+`latlong2` (maps), `mobile_scanner` (QR), `image_picker`
   (camera), `signature`, `fl_chart` are already in pubspec.
2. **Do NOT edit** `lib/core/di/service_locator.dart` (central registration is done for you — just LIST
   the repository classes you created in your final report). Do NOT edit other domains' files,
   `lib/app.dart`, `lib/main.dart`, or `pubspec.yaml`.
3. Models go in `lib/data/models/<thing>.dart` (unique filenames — prefix with your domain if needed).
   Repositories in `lib/data/repositories/<domain>_repository.dart`. Cubits in the consuming feature's
   `lib/features/<role>/cubit/`.
4. Keep the existing widget tree/visuals; only swap the data source. Add **loading / error(with Retry) /
   empty** states (see the reference screen).
5. Read the backend **route file + controller + API Resource** for your cluster to get exact paths,
   query params, request bodies, and JSON shapes. Map API fields to the screen's display fields sensibly
   (e.g. derive initials from name; a field the API lacks can stay a static/derived value — note it).
6. Must pass `flutter analyze <your files>` with no issues. Prefer `const`; use `EdgeInsetsDirectional`.

## Writes & actions
- For create/update/delete and action endpoints (approve, administer dose, confirm pickup, etc.), add
  repository methods and call them from the screen's button handlers; on success show a snackbar / pop /
  refresh, on failure show the mapped error. Keep optimistic UI only where the source did.

## Device features (only if your domain owns them)
- **QR scan** (`mobile_scanner`): replace the mock scanner UI with a real `MobileScanner` where the source
  had the camera mock; on detect, call the verify endpoint. Keep the corner-bracket overlay styling.
- **Camera/photo** (`image_picker`): wire "take/upload photo" buttons to `ImagePicker().pickImage`, then
  upload via multipart (`FormData` / `MultipartFile`) to the relevant endpoint.
- **Maps** (`flutter_map` + OpenStreetMap tiles): replace mock maps with a real `FlutterMap` + `Marker`s.

## Auth/session note
The app already logs in and stores a token. If your screens need the current user/school, you can read it
after login; for now pass/derive what the screen needs from the API responses.

Report back: screens wired, repositories created (class names + file paths for central registration),
endpoints consumed, and anything you had to stub or could not map.
