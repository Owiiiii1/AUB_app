# Cursor Work Report

## Task

Production Stage 1 — Student mobile application UI in `Owiiiii1/AUB_app`. Visual source of truth: `AUB_admin/docs/ref/student/{home,orario,presenze,profile}` (`screen.png`, `DESIGN.md`, `code.html`). Functional source of truth: existing Flutter architecture and API contracts. No new backend.

## References inspected

All four Student folders. Tokens taken from DESIGN/code.html: ivory `#FCF9F8`, navy `#0B192C`, burgundy `#8B2635`, gold `#C5A059`, Oswald + Work Sans, 16px margins, 14–16px card radii, 64px bottom nav. Stitch HTML was not copied. Remote Stitch photos/logo URLs are not used.

## Student screens

- **Shell:** Home / Orario / Presenze / Profilo bottom navigation, shared repositories, SafeArea, selected gold indicator.
- **Home:** real `Ciao, {firstName}` from `/me`; next published/moved lesson on the current week (cancelled excluded); today's lessons including cancelled; month summary without percentages.
- **Orario / Presenze:** existing controllers; Student visual chrome; Parent/Teacher screens not redesigned.
- **Profilo:** display name, class, year, email; logout confirmation. Hidden: notifications, password, 2FA, devices, language, photo edit, classroom directions, artistic announcements.

## Design system

Reusable tokens in `lib/app/theme` and widgets in `lib/shared/widgets` (card, avatar initials, badges, empty/error/loading, header, bottom nav). `ThemeData` rebuilt from Stitch. Fonts bundled as assets.

## Home data

`StudentHomeController` uses `ScheduleRepository` + `AttendanceHistoryRepository`. Next lesson: current week, `Europe/Rome` approximated via injectable `AcademyClock` / device local time, nearest future published/moved lesson. Unmarked lessons are not absences.

## Tests / quality

New selector, controller, and Student UI tests (navigation, home data/empty, schedule statuses, attendance statuses, profile logout). Full suite **83 passed**. `flutter analyze` / `flutter test` / `flutter build apk --debug`.

## Open visual/manual notes

Pixel-perfect Stitch details (decorative blobs, fake VIP corso chips, frequency %, filter sheet) were intentionally omitted. PM will give targeted visual corrections after a device pass. Real academy schedule is still mostly empty; empty states are the production look until teachers publish weeks.
