# API integration

Source of truth: `Owiiiii1/AUB_admin` docs (`docs/ru/API.md`, `docs/en/API.md`). This app does not talk to Bitrix or the Laravel web session.

## Base URL

Default (production, not a secret):

```text
https://aub.owlsolutions.net/api/v1
```

Override at build/run time:

```text
flutter run --dart-define=AUB_API_BASE_URL=https://example.test/api/v1
```

Implemented in `AppConfig` via `String.fromEnvironment('AUB_API_BASE_URL')`. Trailing slashes are stripped.

Release builds refuse a non-HTTPS base URL. TLS certificate validation is not disabled. Certificate pinning is not implemented.

## Endpoints used

| Method | Path | Auth |
|--------|------|------|
| GET | `/health` | No (smoke only) |
| POST | `/auth/login` | No (`skipAuth`) |
| GET | `/me` | Bearer |
| PUT | `/me/password` | Bearer |
| GET | `/me/devices` | Bearer |
| DELETE | `/me/devices/{id}` | Bearer |
| GET | `/schedule` | Bearer, student |
| GET | `/children/{student}/schedule` | Bearer, parent |
| GET | `/teacher/schedule` | Bearer, teacher |
| GET | `/teacher/lessons/{id}/attendance` | Bearer, teacher |
| PUT | `/teacher/lessons/{id}/attendance` | Bearer, teacher |
| GET | `/attendance` | Bearer, student |
| GET | `/children/{student}/attendance` | Bearer, parent |
| POST | `/auth/logout` | Bearer |
| POST | `/auth/logout-all` | Bearer |

Login body:

```json
{
  "email": "user@example.com",
  "password": "…",
  "device_name": "AUB Android"
}
```

`device_name` is a platform label (`AUB Android` / `AUB iOS` / `AUB Windows`). No IMEI, serial, or advertising ID.

Login is not complete until `/me` succeeds. A token without a valid `/me` is deleted.

## Headers

```text
Accept: application/json
Content-Type: application/json
Authorization: Bearer <token>
```

The login request does not send `Authorization`. A 401 from login does **not** start the session-expired flow.

## Error envelope

```json
{
  "success": false,
  "error": {
    "code": "invalid_credentials",
    "message": "…",
    "fields": {}
  }
}
```

Mapped to `ApiException` (`invalid_credentials`, `validation_error`, `unauthenticated`, `forbidden`, `not_found`, `too_many_requests`, `attendance_not_editable`, `server_error`, plus `network` and `timeout` from Dio/socket failures). UI shows Italian strings from `AuthMessages`, never developer/API messages.

## Actor routing

Taken only from `user.account_type` on `/me`:

- `student` → Student Home
- `parent` → Parent Home
- `teacher` → Teacher Home
- anything else (including `staff`) → token cleared, login with unsupported-account error

Actor type is never inferred from JSON field presence.

## Schedule

Student: `GET /schedule?week=YYYY-MM-DD`. Parent: `GET /children/{id}/schedule?week=...` for one child at a time. Teacher: `GET /teacher/schedule?week=...` (own lessons, `academy_class` on each lesson).

The backend converts any date to Monday–Sunday. Flutter sends a date; it does not invent the week bounds. `week.published` and `empty_reason` distinguish unpublished vs empty vs no class vs network error.

Visible lesson statuses: `published`, `cancelled`, `moved`. Cancelled is muted/strikethrough (`Annullata`). Moved shows a `Spostata` badge with the current time from the payload.

Teacher attendance: `GET`/`PUT /teacher/lessons/{id}/attendance`. Identity is Student + ScheduledLesson. PUT is bulk partial upsert; `status: null` removes a mark. No disk cache; each screen open GETs fresh data. Italian labels only (`Presente` / `Assente` / `Giustificato`).

