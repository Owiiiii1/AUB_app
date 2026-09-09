# Current state

Authentication foundation plus student / parent / teacher **Orario**.

## What works

- Splash / session restore, login, logout, actor routing
- Student Home → **Orario** (own class)
- Parent Home → one child at a time → **Orario di {name}**
- Teacher Home → **Orario** → **Il mio orario** (own lessons across classes)
- Week prev/next/Questa settimana
- Vertical 7-day list, today highlight, cancelled/moved badges, class on teacher cards
- Unpublished / no-class / no-lessons / network error with retry (no logout on network errors)
- 401 still uses the global auth flow

## What is intentionally not built

Attendance, check-in, class roster, student details for teacher, push, calendar sync, unified family calendar, report cards, documents, communications, payments, timetable editing, persistent offline cache, final visual design, certificate pinning.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Schedule contract: `GET /schedule`, `GET /children/{student}/schedule`, `GET /teacher/schedule`. Isolated test week `2026-12-28` / class `Mobile Test` has a lesson for the test teacher.
