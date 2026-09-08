# AUB

Mobile app for Accademia Umbra di Belle Arti (students, parents, teachers).

Production API (not a secret): `https://aub.owlsolutions.net/api/v1`

## Run

```text
flutter pub get
flutter run
```

API override:

```text
flutter run --dart-define=AUB_API_BASE_URL=https://example.test/api/v1
```

## Check

```text
flutter analyze
flutter test
flutter build apk --debug
```

## Docs

- `docs/ARCHITECTURE.md`
- `docs/API_INTEGRATION.md`
- `docs/CURRENT_STATE.md`
- `docs/DEVELOPMENT_RULES.md`
- `docs/NEXT_STEPS.md`
