# Architecture

AUB_app is the Flutter client for Accademia Umbra di Belle Arti. Auth foundation plus **student/parent schedule**.

## Layers

| Layer | Responsibility |
|--------|----------------|
| `lib/app` | App widget, config, Italian UI strings |
| `lib/core/api` | Dio client, JSON unwrap, `ApiException` |
| `lib/core/storage` | Token persistence (`flutter_secure_storage`) |
| `lib/features/auth/data` | Endpoints and session orchestration |
| `lib/features/auth/models` | Typed `/me` and login models |
| `lib/features/auth/state` | `AuthController` / `AuthState` |
| `lib/features/auth/presentation` | Splash, login, offline-restore |
| `lib/features/home/presentation` | Actor home placeholders + Orario entry |
| `lib/features/schedule` | API, repository, week state, schedule screen |

UI never calls HTTP. UI never reads the token. Presentation talks to `AuthController` / `ScheduleController`.

There is no Riverpod, Bloc, GetX, or Provider. `AuthController` is a `ChangeNotifier`.

## Directory structure

```text
lib/
  main.dart
  app/
    app.dart
    app_config.dart
    app_strings.dart
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
      presentation/
        student_home_screen.dart
        parent_home_screen.dart
        teacher_home_screen.dart
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
  apiClient.onUnauthorized → controller.handleUnauthorized
  AubApp
```

`ApiClient` holds the current bearer in memory and attaches `Authorization` via an interceptor. The repository is the only code that writes/deletes the token in secure storage and then updates the client.

## Auth state

`initializing` → splash  
`unauthenticated` / `authenticating` → login  
`restoreFailed` → retry (token kept)  
`authenticated` → actor home → **Orario** (student own class / parent one child at a time)
