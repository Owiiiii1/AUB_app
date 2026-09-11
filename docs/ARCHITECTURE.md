# Architecture

AUB_app is the Flutter client for Accademia Umbra di Belle Arti. Auth foundation plus **student production shell** (Home / Orario / Presenze / Profilo), parent/teacher schedule, **teacher attendance marking**, and **student/parent attendance history**.

## AUB Mobile Design References

Visual source of truth: `Owiiiii1/AUB_admin` → `docs/ref`.

- Student: `docs/ref/student/*` (`home`, `orario`, `presenze`, `profile`)
- Parent / Teacher: separate production stages; their Stitch folders exist but are not implemented yet

`DESIGN.md` and `code.html` supply color, type, spacing, radii, and component tokens. `screen.png` is the composition check. Stitch HTML is **reference only** — Flutter uses native widgets, not a web port.

Functional source of truth remains the existing API contracts and Flutter architecture. No fake Stitch demo names in production UI.

## Layers

| Layer | Responsibility |
|--------|----------------|
| `lib/app` | App widget, config, Italian UI strings, `ThemeData` |
| `lib/app/theme` | Shared AUB tokens (colors, type, spacing) |
| `lib/shared/widgets` | Reusable cards, badges, chrome, empty/error/loading |
| `lib/core/api` | Dio client, JSON unwrap, `ApiException` |
| `lib/core/storage` | Token persistence (`flutter_secure_storage`) |
| `lib/features/auth/data` | Endpoints and session orchestration |
| `lib/features/auth/models` | Typed `/me` and login models |
| `lib/features/auth/state` | `AuthController` / `AuthState` |
| `lib/features/auth/presentation` | Splash, login, offline-restore |
| `lib/features/home` | Student shell + dashboard; parent/teacher entry homes |
| `lib/features/profile` | Student profile + logout |
| `lib/features/schedule` | API, repository, week state, schedule screens |
| `lib/features/attendance` | Teacher marking + Student/Parent month history |

UI never calls HTTP. UI never reads the token. Presentation talks to `AuthController` / `ScheduleController` / attendance controllers.

There is no Riverpod, Bloc, GetX, or Provider. `AuthController` is a `ChangeNotifier`.

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
  features/
    auth/
      data/
        auth_api.dart
        auth_repository.dart
      models/
        api_user.dart
        actor_profile.dart
        auth_session.dart
      state/
        auth_controller.dart
        auth_state.dart
      presentation/
        login_screen.dart
        splash_screen.dart
        restore_failed_screen.dart
        auth_messages.dart
    home/
      data/
        student_home_selectors.dart
      state/
        student_home_controller.dart
        student_home_state.dart
      presentation/
        student_shell.dart
        student_home_screen.dart
        parent_home_screen.dart
        teacher_home_screen.dart
    profile/
      presentation/
        student_profile_screen.dart
    schedule/
      data/
        schedule_api.dart
        schedule_repository.dart
      models/
        schedule_week.dart
      state/
        schedule_controller.dart
        schedule_state.dart
      presentation/
        schedule_screen.dart
        widgets/
          schedule_widgets.dart
      schedule_kind.dart
    attendance/
      data/
        attendance_api.dart
        attendance_repository.dart
        attendance_history_repository.dart
      models/
        attendance_models.dart
      state/
        attendance_controller.dart
        attendance_state.dart
        attendance_history_controller.dart
        attendance_history_state.dart
      presentation/
        attendance_screen.dart
        attendance_history_screen.dart
        widgets/
          attendance_widgets.dart
```

## Runtime graph

```text
main()
  AppConfig.fromEnvironment()
  ApiClient (in-memory bearer)
  SecureTokenStorage
  AuthRepository
  AuthController
  ScheduleRepository (in-memory week cache)
  AttendanceRepository (no disk cache)
  AttendanceHistoryRepository (in-memory month cache, no disk)
  apiClient.onUnauthorized → controller.handleUnauthorized
  AubApp
```

`ApiClient` holds the current bearer in memory and attaches `Authorization` via an interceptor. The repository is the only code that writes/deletes the token in secure storage and then updates the client.

## Auth state

`initializing` → splash  
`unauthenticated` / `authenticating` → login  
`restoreFailed` → retry (token kept)  
`authenticated` → student **shell** (Home / Orario / Presenze / Profilo) or parent/teacher home → **Orario** / **Presenze** (parent one child / teacher own lessons). Teacher lesson tap → marking **Presenze**.
