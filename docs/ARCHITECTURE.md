# Architecture

AUB_app is the Flutter client for Accademia Umbra di Belle Arti. Auth foundation plus **student, parent, and teacher production shells**, schedule, **teacher attendance marking**, and **student/parent attendance history**.

## AUB Mobile Design References

Visual source of truth: `Owiiiii1/AUB_admin` → `docs/ref`.

- Student: `docs/ref/student/*` (`home`, `orario`, `presenze`, `profile`) — production-ready
- Parent: `docs/ref/parent/*` (`home`, `children`, `orario`, `presenze`, `profile`) — production-ready
- Teacher: `docs/ref/teacher/*` (`today`, `orario`, `presenze`, `presenzeChilren`, `profile`) — production-ready

`DESIGN.md` and `code.html` supply color, type, spacing, radii, and component tokens. `screen.png` is the composition check. If `DESIGN.md` and the screenshot diverge, screenshot + visual intent win. Stitch HTML is **reference only** — Flutter uses native widgets, not a web port.

Functional source of truth remains the existing API contracts and Flutter architecture. No fake Stitch demo names in production UI. Student, Parent, and Teacher share one design system (`lib/app/theme`, `lib/shared/widgets`).

## Layers

| Layer | Responsibility |
|--------|----------------|
| `lib/app` | App widget, config, Italian UI strings, `ThemeData` |
| `lib/app/theme` | Shared AUB tokens (colors, type, spacing) |
| `lib/shared/widgets` | Reusable cards, badges, chrome, empty/error/loading, child context |
| `lib/core/api` | Dio client, JSON unwrap, `ApiException` |
| `lib/core/storage` | Token persistence (`flutter_secure_storage`) |
| `lib/features/auth/data` | Endpoints and session orchestration |
| `lib/features/auth/models` | Typed `/me` and login models |
| `lib/features/auth/state` | `AuthController` / `AuthState` |
| `lib/features/auth/presentation` | Splash, login, offline-restore |
| `lib/features/home` | Student / Parent / Teacher shells + dashboards |
| `lib/features/profile` | Student / Parent / Teacher profile + logout |
| `lib/features/schedule` | API, repository, week state, schedule screens |
| `lib/features/attendance` | Teacher marking + Student/Parent month history |

UI never calls HTTP. UI never reads the token. Presentation talks to `AuthController` / `ScheduleController` / home and attendance controllers.

There is no Riverpod, Bloc, GetX, or Provider. Controllers are `ChangeNotifier`.

## Parent child context

Parent always has a selected child (`ParentShell._selectedChildId`). Home aggregates every child via `ParentHomeController` (one parallel fetch per child, then in-memory repository cache). Figli / Calendario / Presenze bind to the selected child. `ScheduleController.bindStudent` reloads and ignores stale in-flight responses. Cache keys already include `studentId`.

## Teacher attendance flow

Teacher shell: **Oggi / Orario / Presenze / Profilo**. Roster is a pushed screen from a schedule lesson (Today next-lesson CTA, Orario card, or Presenze worklist). `TeacherHomeController` loads `GET /api/v1/teacher/schedule` once via `ScheduleRepository`. Lesson IDs come only from that authorized payload.

Attendance: GET roster → local draft → explicit **Salva** (changed rows only). `no AttendanceRecord` = unmarked, never absent. Statuses: present / absent / excused. Cancelled lessons are view-only. Unsaved back is confirmed. Completion “Presenze completate” is not shown: the API has no reliable full-roster completion flag.

Academy day / next-lesson / Oggi use `AcademyClock` (`Europe/Rome`), not `DateTime.now()`.

## Directory structure

```text
lib/
  main.dart
  app/
    app.dart
    app_config.dart
    app_strings.dart
    theme/
      aub_colors.dart
      aub_typography.dart
      aub_spacing.dart
      aub_theme.dart
  shared/
    widgets/
      aub_card.dart
      aub_avatar.dart
      aub_status_badge.dart
      aub_feedback.dart
      aub_chrome.dart
      child_card.dart
      child_switcher.dart
      child_context_header.dart
  core/
    api/
      api_client.dart
      api_exception.dart
    storage/
      token_storage.dart
      secure_token_storage.dart
    platform/
      device_name.dart
    media/
      safe_https_url.dart
    time/
      date_only.dart
      clock.dart
  features/
    auth/
      ...
    home/
      data/
        student_home_selectors.dart
      state/
        student_home_controller.dart
        student_home_state.dart
        parent_home_controller.dart
        parent_home_state.dart
        teacher_home_controller.dart
        teacher_home_state.dart
      presentation/
        student_shell.dart
        student_home_screen.dart
        parent_shell.dart
        parent_home_screen.dart
        parent_children_screen.dart
        teacher_shell.dart
        teacher_home_screen.dart
        teacher_presenze_screen.dart
        widgets/teacher_lesson_card.dart
    profile/
      presentation/
        student_profile_screen.dart
        parent_profile_screen.dart
        teacher_profile_screen.dart
    schedule/
      ...
    attendance/
      ...
```

## Runtime graph

```text
main()
  AppConfig.fromEnvironment()
  ApiClient (in-memory bearer)
  SecureTokenStorage
  AuthRepository
  AuthController
  ScheduleRepository (in-memory week cache, keyed by actor + week)
  AttendanceRepository (no disk cache)
  AttendanceHistoryRepository (in-memory month cache, keyed by studentId + month)
  apiClient.onUnauthorized → controller.handleUnauthorized
  AubApp
```

`ApiClient` holds the current bearer in memory and attaches `Authorization` via an interceptor. The repository is the only code that writes/deletes the token in secure storage and then updates the client.

## Auth state

`initializing` → splash  
`unauthenticated` / `authenticating` → login  
`restoreFailed` → retry (token kept)  
`authenticated` → student **shell** (Home / Orario / Presenze / Profilo) or parent **shell** (Home / Figli / Calendario / Profilo, Presenze as child-context screen) or teacher **shell** (Oggi / Orario / Presenze / Profilo, roster as a pushed lesson screen).
