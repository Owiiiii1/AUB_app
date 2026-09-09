# Current state

Authentication foundation plus student / parent / teacher **Orario**, teacher attendance marking, and student / parent **Presenze** history.

## What works

- Splash / session restore, login, logout, actor routing
- Student Home → **Orario** + **Presenze**
- Parent Home → per child **Orario** + **Presenze di {name}**
- Teacher Home → **Orario** → **Il mio orario** (own lessons across classes)
- Teacher lesson tap → marking **Presenze** (roster, marks, Salva; cancelled is read-only)
- Student/Parent month history: prev/next/Questo mese, summary counts, status badges
- Empty month: `Nessuna presenza registrata questo mese.` (`no AttendanceRecord` ≠ absent)
- Week prev/next/Questa settimana
- Vertical 7-day list, today highlight, cancelled/moved badges, class on teacher cards
- Unpublished / no-class / no-lessons / network error with retry (no logout on network errors)
- 401 still uses the global auth flow

## What is intentionally not built

Percentages, streaks, absence warnings, justification, check-in, class roster beyond the lesson, student details for teacher, push, calendar sync, unified family calendar, report cards, documents, communications, payments, timetable editing, persistent offline cache, final visual design, certificate pinning.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Schedule: `GET /schedule`, `GET /children/{student}/schedule`, `GET /teacher/schedule`. Teacher attendance: `GET`/`PUT /teacher/lessons/{id}/attendance`. History: `GET /attendance`, `GET /children/{student}/attendance`. Isolated test week `2026-12-28` / class `Mobile Test` / lesson `LEZIONE CLASSICO` (id 2).
