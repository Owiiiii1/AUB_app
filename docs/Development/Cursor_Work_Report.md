# Cursor Work Report

## Task

Add Flutter **Teacher Attendance (Presenze)** in `Owiiiii1/AUB_app` after the production Teacher Attendance API.

## UX

Teacher Orario lesson card is tappable (chevron). Student/Parent cards are not.

Header: title, class, `16:00 – 17:30`, room. Roster chips: **Presente** / **Assente** / **Giustificato**. **Segna tutti presenti** is local only until **Salva**. Salva disabled when clean. Unsaved back: `Hai modifiche non salvate. Uscire senza salvare?`. Cancelled: badge `Lezione annullata`, chips disabled, no Salva. PUT/network failure keeps local marks and dirty=true. 401 uses global auth handling. No disk cache; reopen always GETs.

## State

`AttendanceController` holds the GET roster as source of truth plus a draft map. Dirty = draft differs from saved marks. Save sends only changed rows (bulk partial upsert). Success response replaces roster; dirty=false; compact `Salvato` text.

## Tests

Results:

- `flutter pub get` — PASS
- `flutter analyze` — PASS (No issues found)
- `flutter test` — PASS, **58** tests (previous 43 + attendance parsing/controller/UI)
- `flutter build apk --debug` — PASS (`build\app\outputs\flutter-apk\app-debug.apk`)

## E2E

Backend production smoke already verified isolated lesson id **2** / student **8**: present → absent → unmarked, student 403, row cleaned. Widget tests cover roster, chips, mark-all, cancelled read-only, dirty back dialog, teacher chevron vs student card. Device walkthrough on a debug APK is the remaining manual check (`teacher@admin.com`, week `2026-12-28`).

## Files

Created: `lib/features/attendance/**`, attendance tests/helpers.

Modified: `ApiClient.put`, `ApiErrorCode.attendanceNotEditable`, schedule tiles (teacher tap), `AubApp` / `main`, strings, docs.

## Out of scope

Student/Parent attendance history, percentages, notifications, late, comments, admin dashboard, check-in, roster snapshots, finalization lock.
