# Cursor Work Report

## Task

Production Stage 3 — Teacher mobile application UI (`Owiiiii1/AUB_app`).

## References inspected

`AUB_admin/docs/ref/teacher/{today,orario,presenze,presenzeChilren,profile}` — each `screen.png`, `DESIGN.md`, `code.html`. Folder name `presenzeChilren` used as-is.

Stitch bottom nav is **Oggi / Orario / Presenze / Profilo**. Screenshot + HTML intent win over the generic `DESIGN.md` token dump. Stitch `presenze` is a per-lesson roster editor; `presenzeChilren` is a post-save summary with percentages, matricola, and SMS — those fields are not in the attendance API and were not invented. Presenze tab is a real current-week lesson worklist; roster is a pushed route.

Stitch demo names (Maria Rossi, Classe A, Danza Classica, Sala 2, 20 studenti, DOC-1982-AUB) are not hardcoded.

## Teacher shell

`TeacherShell`: IndexedStack + `AubAppHeader` (mark **Docenti**) + `TeacherBottomNav` (Oggi / Orario / Presenze / Profilo). Student and Parent shells unchanged. Shared chrome stays backward-compatible (`AubAppHeader.mark`).

## Today architecture

`TeacherHomeController` + `TeacherHomeState` load `ScheduleRepository.load(kind: teacher)` once. Next lesson and today's lessons use `AcademyClock` / Europe/Rome via existing selectors. Cancelled lessons are excluded from next-lesson. Published and moved can be next. UI shows **Apri presenze**, not fake “Presenze completate / Da compilare”.

## Schedule reuse

Teacher Orario is `ScheduleScreen` (`kind: teacher`, `studentVisuals`, `onLessonTap`) with the existing week nav, `Questa settimana`, statuses, empty, Retry, and 401 handling. Teacher cards show class and **Apri presenze** without changing the student presentation path.

## Attendance flow

Oggi → Prossima lezione → Apri presenze → roster → Segna → Salva.  
Orario / Presenze list → lesson → roster.

Lesson IDs come only from the authorized teacher schedule. Roster payload is unchanged: `display_name`, `photo_url`, `attendance` only. No tax_code, medical, parent contacts, notes, or admin fields.

## Roster behavior

Existing `AttendanceController` kept: GET, local draft, no autosave, changed rows only, PUT, success replaces source of truth, network error keeps draft, 401 does not wipe draft. **Segna tutti presenti** is draft-only. Save disabled when clean. Cancelled → `Lezione annullata`, controls off. Unsaved back: `Hai modifiche non salvate.\nUscire senza salvare?`. Unmarked ≠ absent. List uses slivers for 20–30 students.

## Profile reuse

`TeacherProfileScreen` uses `/me` name + email + Docente. Password, devices, language, local push, and logout match Parent/Student. No fake A.A., teacher code, courses, 2FA, or check-in.

## Europe/Rome

Greeting, next lesson, today list, ongoing **Adesso**, Oggi highlight, and `ScheduleController.loadToday` use `AcademyClock`. No `DateTime.now()` in academy selectors.

## Privacy

Roster shows only attendance-API fields. Stitch matricola / medical notes / SMS / percentages omitted.

## Tests

`test/teacher_ui_test.dart`: shell/nav, Today name/next/today/moved/cancelled/empty, Orario own lessons/class/week nav/moved/cancelled/empty, Presenze list → roster, roster unmarked/present/absent/excused/mark-all/save/cancelled/network draft/unsaved back, profile + logout. Routing test updated. Existing Student + Parent + attendance tests remain.

## Quality

`flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.

## Manual visual notes

Hierarchy vs Stitch: greeting → Prossima lezione → Le lezioni di oggi; Orario week cards with class/room/status; Presenze = week worklist; roster = class/title/time/room + status chips + sticky Salva; Profilo = identity + real settings. Fake Stitch blocks skipped (riepilogo compiti, secretariat memo, completion %, matricola, 2FA). Intended to fit 360/390/430; SafeArea via scaffold header/nav. Student and Parent screens not restyled except shared header `mark` and teacher-only schedule card extras.
