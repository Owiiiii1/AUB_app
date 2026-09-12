# Current state

Authentication plus **Student production UI** and **Parent production UI** (Stitch-aligned shells), teacher functional home, schedule, teacher attendance marking, and student/parent **Presenze** history.

**Student UI ✅ · Parent UI ✅ · Teacher UI pending**

## What works

- Splash / session restore, login, logout, actor routing
- Student shell: bottom nav **Home / Orario / Presenze / Profilo**
- Parent shell: bottom nav **Home / Figli / Calendario / Profilo** (Presenze is a child-context screen, not a global tab — matches `docs/ref/parent`)
- Student Home dashboard from existing APIs: greeting from `/me`, next lesson and today's lessons from current week schedule, month attendance summary (absolute counts only)
- Parent Home dashboard: greeting (`AcademyClock` / Europe/Rome), child cards from `ParentProfile.children`, next lesson + attendance counts per child, aggregated upcoming lessons. Data from `GET /children/{id}/schedule` and `GET /children/{id}/attendance`, loaded once via `ParentHomeController` + repository cache
- Empty copy: `Nessuna lezione programmata`, `Nessuna lezione in programma oggi.`, `Nessuna presenza registrata questo mese.`, `Nessun allievo associato a questo account.` (`no AttendanceRecord` ≠ absent)
- Student/Parent Orario / Presenze: week/month navigation, published/moved/cancelled, retry, 401 global handling
- Parent child context: selected child visible on Figli/Calendario; switching reloads schedule and does not leave sibling data on screen
- Student Profilo: identity + read-only phone / birth date / address + password + devices + language + local push + logout
- Parent Profilo: `/me` name, email, enrolled children, password + devices + language + local push + logout
- Teacher Home → **Orario** → marking **Presenze**
- Fonts: bundled Oswald + Work Sans from the Stitch palette

## What is intentionally not built

Teacher visual production stage, percentages, streaks, absence warnings, justification, check-in, push delivery (FCM), calendar sync, profile editing, documents, communications, payments, timetable editing, persistent offline cache, certificate pinning, fake Stitch notices/billing/2FA.

## Backend

Production API: `https://aub.owlsolutions.net/api/v1`

Student Home reuses `GET /me`, `GET /schedule`, `GET /attendance`. Parent Home reuses `GET /me`, `GET /children/{student}/schedule`, `GET /children/{student}/attendance`. Profile uses `GET /me`, `PUT /me/password`, `GET /me/devices`, `DELETE /me/devices/{id}`, `POST /auth/logout-all`. Language and push toggles are local only.
