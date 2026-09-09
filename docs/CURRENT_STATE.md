# Current state

Authentication foundation plus student/parent **Orario**.

## What works

- Splash / session restore, login, logout, actor routing
- Student Home → **Orario** (own class)
- Parent Home → one child at a time → **Orario di {name}**
- Week prev/next/Questa settimana
- Vertical 7-day list, today highlight, cancelled/moved badges
- Unpublished / no-class / network error with retry (no logout on network errors)
- 401 still uses the global auth flow

## What is intentionally not built

Teacher schedule, attendance, check-in, push, calendar sync, unified family calendar, report cards, documents, communications, payments, timetable editing, persistent offline cache, final visual design, certificate pinning.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Schedule contract: `GET /schedule`, `GET /children/{student}/schedule`. Isolated test week `2026-12-28` exists for class `Mobile Test` (test student).
