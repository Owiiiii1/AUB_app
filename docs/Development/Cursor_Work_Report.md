# Cursor Work Report

## Task

Implement Flutter **Student / Parent Schedule (Orario)** in `Owiiiii1/AUB_app` after the production schedule API on `Owiiiii1/AUB_admin`. Teacher schedule is out of scope.

## Architecture

Same auth stack as before. Schedule is a feature slice:

- `ScheduleApi` — `GET /schedule`, `GET /children/{id}/schedule`
- `ScheduleRepository` — session in-memory cache only (`self|current` / `{id}|YYYY-MM-DD`)
- `ScheduleController` / `ScheduleState` — `loading` / `loaded` / `unpublished` / `error`
- `ScheduleScreen` + widgets — vertical 7-day list
- Home screens open Orario via `Navigator` (no router package)

UI never calls HTTP. Week bounds come from the backend (`starts_on` / `ends_on`). Prev/next use the returned Monday ± 7 days. `intl` 0.20.3 for Italian weekday/month names only (no l10n framework).

## Screens

- Student Home → **Orario** → own class week
- Parent Home → per child **Orario** → `Orario di {display_name}`
- Week header: `<  7–13 settembre 2026  >` plus **Questa settimana**
- All 7 days listed; empty days compact `Nessuna lezione`
- Today highlighted when the displayed week contains today
- Cancelled: muted + strikethrough + `Annullata`
- Moved: `Spostata` badge, current time from payload
- Unpublished / no class / network error with Retry; network errors do not logout
- 401 delegated to existing global auth interceptor

## State

`ScheduleStatus`: `loading`, `loaded`, `unpublished`, `error`.

`empty_reason` from API:

- `unpublished` → unpublished empty UI
- `no_class` / `no_lessons` / `null` → loaded (empty days or lessons)
- Network → `error` + Retry, previous week kept when available

Parent always passes one `studentId`. Schedules of siblings are not mixed.

## Tests

Mocked/fake transport only. No production credentials.

- Parsing: normal week, cancelled, moved, empty, malformed, draft status rejected
- Controller: current / previous / next, unpublished, network error, 401 stays without schedule error, parent child id transmitted
- UI: student lesson, parent header name, unpublished copy, cancelled/moved badges
- Existing auth + routing tests still run

Results:

- `flutter pub get` — PASS
- `flutter analyze` — PASS (No issues found)
- `flutter test` — PASS, **33** tests
- `flutter build apk --debug` — PASS (`build\app\outputs\flutter-apk\app-debug.apk`)

## E2E

Backend production smoke already covered real actors:

- Student `student@admin.com` → own schedule 200
- Parent `parent@admin.com` → own child 200, unrelated student 404
- Isolated published week `2026-12-28` / class `Mobile Test` (test student only)

Device/emulator walkthrough of Orario is the remaining manual check on a debug APK. Passwords are not stored in this repo.

## Files

Created under `lib/features/schedule/`, `lib/core/time/`, `test/schedule_*`, `test/helpers/schedule_*` / `fake_schedule_api.dart`. Updated auth homes, `AubApp`, `ApiClient.get(query:)`, `pubspec.yaml` (`intl`), docs.

## Out of scope (unchanged)

Teacher schedule, attendance, check-in, push, calendar sync, unified family calendar, report cards, documents, payments, mobile timetable editing, persistent offline cache.
