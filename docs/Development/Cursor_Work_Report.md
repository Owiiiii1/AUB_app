# Cursor Work Report

## Task

Add Flutter **Student / Parent Attendance History** after production `GET /attendance` and `GET /children/{student}/attendance`. Reuse `features/attendance`. Teacher marking unchanged.

## Architecture

One attendance feature, two flows:

- Teacher marking: `AttendanceController` / `AttendanceScreen` / `AttendanceRepository`
- History: `AttendanceHistoryController` / `AttendanceHistoryScreen` / `AttendanceHistoryRepository`

`AttendanceApi` adds `loadStudentAttendance` / `loadChildAttendance`. UI does not know paths.

In-memory month cache only (`self|{month}` vs `{studentId}|{month}`). No disk. Logout drops the runtime repository.

## Screens / state

Student Home: **Orario** + **Presenze**. Parent Home: per child **Orario** + **Presenze**. Title `Presenze` / `Presenze di {name}`. Month header + Questo mese. Summary Totale / Presenti / Assenti / Giustificati. Records grouped by date. Status chips Presente / Assente / Giustificato. Empty: `Nessuna presenza registrata questo mese.`

States: `loading` / `loaded` / `empty` / `error`. Network retry. 401 global. No logout on network error.

## Tests

Parsing (present/absent/excused/empty/malformed), repository/controller (student/parent endpoints, month nav, empty, network, 401, cache isolation), UI (home actions, title, summary, records, empty, prev/next). Full suite **74 passed**. `flutter analyze` / `flutter test` / `flutter build apk --debug` PASS.
