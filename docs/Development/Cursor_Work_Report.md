# Cursor Work Report

## Task

Implement the Flutter **Authentication Foundation** in `Owiiiii1/AUB_app` only. Remove the counter demo. Restore session, log in against `https://aub.owlsolutions.net/api/v1`, store the Sanctum token in secure storage, route by `user.account_type`, and show placeholder homes with real `/me` data. `AUB_admin` was not changed.

## Before

The repo was the default Flutter counter template (`MyApp` / `_counter`). No API client, no auth, no secure storage, no actor routing, no project docs.

## After

App lifecycle:

```text
App start → Splash / restoreSession
  no token → Login
  token → GET /me
    200 → Student / Parent / Teacher Home
    401 → delete token → Login
    network/timeout → keep token → retry
```

Login:

```text
POST /auth/login → secure storage → ApiClient bearer → GET /me → actor home
```

## Dependencies

From `pubspec.lock` (Flutter 3.38.7 / Dart 3.10.7, no `flutter upgrade`):

| Package | Constraint | Resolved |
|---------|------------|----------|
| `dio` | `^5.9.0` | **5.11.1** |
| `flutter_secure_storage` | `^10.0.0` | **10.3.1** |
| `cupertino_icons` | `^1.0.8` | 1.0.9 |
| `flutter_lints` | `^6.0.0` | (dev) |

No Riverpod, Bloc, GetX, Provider, json_serializable, or connectivity_plus.

## Architecture

Simple services + repository + models + `ChangeNotifier`:

- `AppConfig` — base URL + `--dart-define=AUB_API_BASE_URL`
- `ApiClient` — Dio, JSON headers, timeouts (10s connect / 15s send / 15s receive), in-memory bearer interceptor, error envelope → `ApiException`
- `SecureTokenStorage` — key `aub_access_token`
- `AuthApi` — `/auth/login`, `/me`, `/auth/logout`, `/auth/logout-all`
- `AuthRepository` — token orchestration; UI never sees URLs or the token
- `AuthController` / `AuthState` — `initializing`, `unauthenticated`, `authenticating`, `authenticated`, `restoreFailed`
- Presentation: splash, login (Italian), three home placeholders

## Auth lifecycle

`AuthController.restoreSession()` reads the token, sets bearer, calls `/me`. Missing token → login. 401 → delete token → login. Network/timeout → **token kept**, retry UI. Login is authenticated only after `/me` succeeds.

## Secure storage

`flutter_secure_storage` 10.3.1:

- Android: default `AndroidOptions()` (RSA OAEP + AES-GCM, no biometrics). `minSdk` at least 23.
- iOS: Keychain `first_unlock_this_device`. No extra capabilities. Bundle id unchanged: `com.owlsolutions.aub`.

Token is not stored in SharedPreferences, files, or Hive.

## API integration

Default base URL: `https://aub.owlsolutions.net/api/v1`

Backend docs (`AUB_admin/docs/ru/API.md` / `docs/en/API.md`) are the JSON contract. Login sends `email`, `password`, `device_name` (`AUB Android` / `AUB iOS` / `AUB Windows`). Bearer is attached centrally. Login uses `skipAuth` so a login 401 does not trigger session-expired handling.

## Actor routing

Only `user.account_type`: `student` / `parent` / `teacher`. `staff` or unknown → token cleared, unsupported-account error, login. Never inferred from JSON field presence.

## Error handling

`ApiException` covers `invalid_credentials`, `validation_error`, `unauthenticated`, `forbidden`, `not_found`, `too_many_requests`, `server_error`, `network`, `timeout`. UI strings (Italian) live in `AppStrings` / `AuthMessages`.

## Security

- Token only in secure storage + ApiClient memory
- HTTPS; release refuses non-HTTPS base URL
- TLS validation on; no accept-all certificates; no pinning (later decision)
- No token/password/`Authorization` logging
- Password controller cleared on dispose / successful login
- `/me` not persisted to disk
- No backend secrets in the app
- No `usesCleartextTraffic=true`

## Tests

Mocked/fake transport only. No production credentials.

- Model parsing: student, parent, teacher, malformed, staff/unknown
- AuthController: no token; valid restore; 401 removes token; network keeps token; login success; login failure; unsupported actor (login + restore); logout removes token even if server fails
- UI: splash; login; student/parent/teacher homes

Results:

- `flutter pub get` — PASS
- `flutter analyze` — PASS (No issues found)
- `flutter test` — PASS, **19** tests
- `flutter build apk --debug` — PASS (`build\app\outputs\flutter-apk\app-debug.apk`)

## Production health smoke

`GET https://aub.owlsolutions.net/api/v1/health` → **200**

```json
{"success":true,"data":{"status":"ok","api_version":"v1"}}
```

No production actor accounts were created for this Flutter task.

## Files changed

Created under `lib/`, `test/`, `docs/`. Updated `pubspec.yaml`, `README.md`, Android manifest (INTERNET, label AUB), Android `minSdk >= 23`, iOS display name AUB. Removed counter demo and default `widget_test.dart`.

## Technical debt / OPEN

- No real device E2E login until test actor accounts exist
- `logout-all` is in `AuthApi` but not exposed in UI
- No certificate pinning
- No localization framework (Italian strings only)
- Home screens are placeholders (no schedule/attendance)
- Debug APK still uses Flutter debug signing

## Next recommended step

**Create test actor accounts + real end-to-end Flutter login**, then the first feature slice, most likely Student/Parent Home + schedule.
