# Cursor Work Report

## Task

Production Stage 2 — Parent mobile application UI (`Owiiiii1/AUB_app`).

## References inspected

`AUB_admin/docs/ref/parent/{home,children,orario,presenze,profile}` — each `screen.png`, `DESIGN.md`, `code.html`.

Stitch bottom nav is **Home / Figli / Calendario / Profilo**. Presenze is a child-context screen, not a global tab. `DESIGN.md` is a generic token dump; layout follows screenshot + HTML intent. Stitch demo names (Sofia Rossi, Classe A, …) are not hardcoded.

## Parent shell

`ParentShell`: IndexedStack + `AubAppHeader` + `ParentBottomNav` (Home / Figli / Calendario / Profilo). Student shell unchanged (Home / Orario / Presenze / Profilo). Shared chrome stays backward-compatible (`AubAppHeader` accepts `avatarName` / `photoUrl` as well as `StudentProfile`).

## Child context architecture

Selected child lives in `ParentShell`, not inside widgets. `ParentHomeController` loads every child’s current-week schedule and current-month attendance once (`Future.wait`), then derives next lesson / today / upcoming with `AcademyClock`. Repositories keep in-memory caches keyed by `studentId`. `ScheduleController.bindStudent` reloads on switch and drops stale in-flight responses so Child A data cannot remain under Child B.

## Shared components

Presentation-only: `ChildSwitcher`, `ChildCard`, `ChildContextHeader`. No HTTP inside. Teacher can reuse later.

## Home data sources

Authenticated `ParentProfile` + `GET /children/{id}/schedule` + `GET /children/{id}/attendance`. No new backend. No per-rebuild N requests. No new Dio client per child.

Skipped fake Stitch blocks with no API: avvisi, presidio, A.A. year on children, live “In Accademia”, attendance %, giustificazione, billing, 2FA.

## Empty states

No children, no class, no schedule, no attendance, no next lesson — production copy, not nulls or empty Stitch cards.

## Europe/Rome

Greeting, next lesson, today rest, day-boundary “Oggi”, `ScheduleController.loadToday`, and schedule “today” highlights use `AcademyClock`.

## Tests

`test/parent_ui_test.dart`: shell/nav, one/many/no children, child switching + sibling isolation, home name/cards/next/attendance/empty, orario published/moved/cancelled/empty, presenze statuses + empty month, profile + logout. Routing and parent Presenze tests updated.

## Quality

`flutter pub get`, `flutter analyze`, `flutter test`, `flutter build apk --debug`.

## Manual visual notes

Hierarchy matches Stitch: greeting → I tuoi figli cards → prossimi impegni; Figli = switcher + selected-child detail; Calendario = child header + existing student week UI; Presenze pushed with child title; Profilo = identity + enrolled children + real settings. No overflow intended at 360/390/430; SafeArea via scaffold header/nav. Student UI not restyled except shared today-clock and header avatar generalization.
