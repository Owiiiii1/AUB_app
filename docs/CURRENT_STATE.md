# Current state

Authentication foundation is in place. The Flutter counter demo is gone.

## What works

- Splash / session restore on startup
- Login (`POST /auth/login` + `GET /me`)
- Secure token storage (`flutter_secure_storage`, key `aub_access_token`)
- Actor routing: student / parent / teacher placeholder homes with real `/me` fields
- Logout (local token always removed, even if the network call fails)
- Global 401 → local logout → login (login 401 excluded)
- Offline restore keeps the token and shows retry
- Production API base URL with `--dart-define` override
- Italian login/error copy without a full l10n system

## What is intentionally not built

Registration, password reset, biometrics, refresh tokens, push, schedule, attendance, teacher check-in, report card, documents, communications, payments, production groups, final visual design, certificate pinning.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

This Flutter task does not change `AUB_admin`. Real actor accounts for end-to-end login are a later PM/backend step.
