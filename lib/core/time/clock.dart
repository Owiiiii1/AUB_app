import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

const academyTimeZoneName = 'Europe/Rome';

bool _timeZonesReady = false;

void ensureAcademyTimeZones() {
  if (_timeZonesReady) {
    return;
  }
  tzdata.initializeTimeZones();
  _timeZonesReady = true;
}

tz.Location academyLocation() {
  ensureAcademyTimeZones();
  return tz.getLocation(academyTimeZoneName);
}

/// Instant in the academy calendar (`Europe/Rome`), including CET/CEST.
tz.TZDateTime academyDateTime(
  int year,
  int month,
  int day, [
  int hour = 0,
  int minute = 0,
  int second = 0,
]) {
  return tz.TZDateTime(academyLocation(), year, month, day, hour, minute, second);
}

/// Interprets a lesson `YYYY-MM-DD` + `HH:mm` as academy-local time.
tz.TZDateTime? academyLessonStart(DateTime date, String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return academyDateTime(date.year, date.month, date.day, hour, minute);
}

/// Converts [value] into academy-local time.
///
/// * UTC / [tz.TZDateTime] values are converted from the true instant.
/// * Naive local [DateTime]s (typical in tests) keep their calendar components
///   as Europe/Rome wall-clock, so tests do not depend on the device timezone.
tz.TZDateTime toAcademyTime(DateTime value) {
  ensureAcademyTimeZones();
  if (value is tz.TZDateTime) {
    return tz.TZDateTime.from(value, academyLocation());
  }
  if (value.isUtc) {
    return tz.TZDateTime.from(value, academyLocation());
  }
  return academyDateTime(
    value.year,
    value.month,
    value.day,
    value.hour,
    value.minute,
    value.second,
  );
}

class AcademyClock {
  const AcademyClock({DateTime Function()? now}) : _instant = now;

  final DateTime Function()? _instant;

  /// Current academy-local time in `Europe/Rome`, independent of device TZ.
  DateTime now() {
    final provided = _instant?.call();
    if (provided == null) {
      return tz.TZDateTime.now(academyLocation());
    }
    return toAcademyTime(provided);
  }
}
