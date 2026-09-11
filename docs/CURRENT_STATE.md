# Current state

Authentication plus **Student production UI** (Stitch-aligned shell), parent/teacher functional homes, schedule, teacher attendance marking, and student/parent **Presenze** history.

## What works

- Splash / session restore, login, logout, actor routing
- Student shell: bottom nav **Home / Orario / Presenze / Profilo**
- Student Home dashboard from existing APIs: greeting from `/me`, next lesson and today's lessons from current week schedule, month attendance summary (absolute counts only)
- Empty Home/Presenze copy: `Nessuna lezione programmata`, `Nessuna lezione in programma oggi.`, `Nessuna presenza registrata questo mese.` (`no AttendanceRecord` ≠ absent)
- Student Orario / Presenze restyled; week/month navigation, statuses, retry, 401 global handling unchanged
- Student Profilo: real `/me` identity + working logout (no fake settings)
- Parent Home → per child **Orario** + **Presenze di {name}** (not redesigned)
- Teacher Home → **Orario** → marking **Presenze**
- Fonts: bundled Oswald + Work Sans from the Stitch palette

## What is intentionally not built

Parent/Teacher visual production stages, percentages, streaks, absence warnings, justification, check-in, push, calendar sync, profile editing, documents, communications, payments, timetable editing, persistent offline cache, certificate pinning.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Student Home reuses `GET /me`, `GET /schedule`, `GET /attendance`. No new backend endpoints.
