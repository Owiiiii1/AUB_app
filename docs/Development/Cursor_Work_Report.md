# Cursor Work Report

## Task

Add Flutter **Teacher Schedule (Orario)** in `Owiiiii1/AUB_app` after the production `GET /teacher/schedule` API. Reuse `features/schedule`. Student/Parent Orario unchanged.

## Architecture

One schedule feature, three `ScheduleKind` values: `student`, `child`, `teacher`.

- `ScheduleApi.teacherWeek()` → `/teacher/schedule`
- `ScheduleRepository` cache keys: `self|…`, `{childId}|…`, `teacher|…`
- `ScheduleController` takes `kind` + optional `studentId`
- Shared `ScheduleScreen` / week header / status badges
- Teacher Home **Orario** → **Il mio orario**
- Lesson `academyClass?` is nullable so Student/Parent JSON still parses

## Screens / state

Same `loading` / `loaded` / `unpublished` / `error`. Teacher cards show class + `building · room`. Cancelled `Annullata`, moved `Spostata`. Empty published week: `Nessuna lezione questa settimana`. Today highlight unchanged. In-memory cache only.

## Tests

- Parsing: teacher week, two classes, cancelled/moved, empty, malformed
- Controller: teacher endpoint, cache isolation, unpublished, network error
- UI: Teacher Home Orario, Il mio orario, academy class, empty copy
- Existing auth + student/parent schedule tests remain

Results:

- `flutter pub get` — PASS
- `flutter analyze` — PASS (No issues found)
- `flutter test` — PASS, **43** tests
- `flutter build apk --debug` — PASS (`build\app\outputs\flutter-apk\app-debug.apk`)

## E2E

Backend production smoke already used `teacher@admin.com`: current week unpublished 200; isolated `2026-12-28` published with `LEZIONE CLASSICO` / `Mobile Test`; student token 403. Widget tests cover Teacher Home → Orario and schedule rendering. Device/emulator walkthrough is the remaining manual check on a debug APK.

## Files

Created: `lib/features/schedule/schedule_kind.dart`.

Modified: schedule models/api/repository/controller/UI, Teacher Home, `AubApp`, strings, tests, docs.

## Out of scope

Attendance, roster, check-in, notes, substitutes, editing, push, persistent cache.
