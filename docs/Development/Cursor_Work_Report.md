# Cursor Work Report

## Task

Fix Student Home academy time before closing Student Production Stage 1. `AcademyClock` must not use device `DateTime.now()` timezone for Oggi, Prossima lezione, or the day boundary. Source of truth is IANA `Europe/Rome` (CET/CEST).

## What changed

- Added `timezone` and IANA `Europe/Rome`.
- `AcademyClock.now()` returns academy-local `TZDateTime` in `Europe/Rome`, independent of the phone timezone.
- Still injectable: `AcademyClock(now: () => …)`. UTC instants convert from the true instant; naive test `DateTime`s keep wall-clock components as Rome so existing tests are not device-TZ dependent.
- Student Home selectors (`todaysLessons`, `findNextLesson`) and the next-lesson countdown compare academy-local instants via `academyLessonStart` / `toAcademyTime`.
- `main()` initializes timezone data. Schedule backend week bounds are unchanged.

No hardcoded UTC+1 / UTC+2 and no manual DST table.

## Tests

- Instant when another TZ is still the previous calendar day and Rome is already the next day → Home uses Rome day.
- DST: summer CEST (UTC+2) and winter CET (UTC+1).
- Existing Student Home tests remain green.

## Commands

`flutter pub get`, `flutter analyze`, `flutter test` (**86 passed**), `flutter build apk --debug`.
