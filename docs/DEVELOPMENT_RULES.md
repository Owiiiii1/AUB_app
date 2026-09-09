# Development rules

- Flutter client only in this repo. Do not put Bitrix URLs, `APP_KEY`, DB credentials, or other backend secrets in the app.
- Production API: `https://aub.owlsolutions.net/api/v1`. Override with `--dart-define=AUB_API_BASE_URL=...`.
- Token lives in `flutter_secure_storage` only. Never SharedPreferences, files, Hive, or SQLite for the access token.
- Do not log tokens, passwords, `Authorization`, or login response bodies.
- Do not disable TLS validation. Do not set `usesCleartextTraffic=true` unless a later debug-only HTTP override is explicitly approved.
- Release must use HTTPS.
- UI must not call Dio or read secure storage.
- Actor type comes from `user.account_type`, never from guessing JSON fields.
- A 401 on authenticated routes clears the session. Login 401 must not.
- Transient network errors during restore must not delete a stored token.
- Keep Italian user-facing strings in `AppStrings` / `AuthMessages`. Do not scatter copy.
- Do not add Riverpod/Bloc/GetX/Provider unless a later stage needs them.
- Do not run `flutter upgrade` unless asked.
- Bundle id stays `com.owlsolutions.aub`.
- Tests must not contain production credentials.
- Schedule week cache is in-memory for the session only. Do not persist child, student, or teacher schedules to disk.
- Flutter does not invent week bounds. Send `?week=YYYY-MM-DD`; the backend returns Monday–Sunday.
