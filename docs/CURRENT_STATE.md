# Current state

Authentication plus **Student production UI**, **Parent production UI**, and **Teacher production UI** (Stitch-aligned shells), schedule, teacher attendance marking, and student/parent **Presenze** history.

**Student UI ✅ · Parent UI ✅ · Teacher UI ✅**

## What works

- Splash / session restore, login, logout, actor routing
- Student shell: bottom nav **Home / Orario / Presenze / Profilo**
- Parent shell: bottom nav **Home / Figli / Calendario / Profilo** (Presenze is a child-context screen, not a global tab — matches `docs/ref/parent`)
- Teacher shell: bottom nav **Oggi / Orario / Presenze / Profilo**
- Student Home dashboard from existing APIs: greeting from `/me`, next lesson and today's lessons from current week schedule, month attendance summary (absolute counts only)
- Parent Home dashboard: greeting (`AcademyClock` / Europe/Rome), child cards from `ParentProfile.children`, next lesson + attendance counts per child, aggregated upcoming lessons. Data from `GET /children/{id}/schedule` and `GET /children/{id}/attendance`, loaded once via `ParentHomeController` + repository cache
- Teacher Oggi dashboard: greeting from `/me`, next lesson and today's lessons from `GET /teacher/schedule` via `TeacherHomeController` + `ScheduleRepository`. Cancelled lessons are not next-lesson candidates. No fake attendance-completion state
- Empty copy: `Nessuna lezione programmata`, `Nessuna lezione in programma oggi.`, `Nessuna presenza registrata questo mese.`, `Nessun allievo associato a questo account.`, `Nessuna lezione da registrare in questa settimana.` (`no AttendanceRecord` ≠ absent)
- Student/Parent/Teacher Orario: week navigation, published/moved/cancelled, retry, 401 global handling
- Parent child context: selected child visible on Figli/Calendario; switching reloads schedule and does not leave sibling data on screen
- Teacher Presenze: current-week lesson worklist → roster. Draft marking, **Segna tutti presenti**, explicit **Salva**, unsaved-back warning, cancelled view-only
- Student Profilo: identity + read-only phone / birth date / address + password + devices + language + local push + logout
- Parent Profilo: `/me` name, email, enrolled children, password + devices + language + local push + logout
- Teacher Profilo: `/me` name, email, role Docente, password + devices + language + local push + logout
- Fonts: bundled Oswald + Work Sans from the Stitch palette

## What is intentionally not built

Percentages, streaks, absence warnings, justification, check-in, geolocation, push delivery (FCM), calendar sync, profile editing, documents, communications, payments, timetable editing, persistent offline cache, certificate pinning, fake Stitch notices/billing/2FA/teacher codes, attendance completion flags.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Student Home reuses `GET /me`, `GET /schedule`, `GET /attendance`. Parent Home reuses `GET /me`, `GET /children/{student}/schedule`, `GET /children/{student}/attendance`. Teacher Home / Orario / Presenze list reuse `GET /teacher/schedule`. Teacher roster uses `GET`/`PUT /teacher/lessons/{scheduledLesson}/attendance`. Profile uses `GET /me`, `PUT /me/password`, `GET /me/devices`, `DELETE /me/devices/{id}`, `POST /auth/logout-all`. Language and push toggles are local only.
