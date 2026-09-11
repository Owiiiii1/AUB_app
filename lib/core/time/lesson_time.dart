DateTime? combineDateAndClock(DateTime date, String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length < 2) {
    return null;
  }
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) {
    return null;
  }
  return DateTime(date.year, date.month, date.day, hour, minute);
}

int? durationMinutes(String startsAt, String endsAt) {
  final start = combineDateAndClock(DateTime(2000), startsAt);
  final end = combineDateAndClock(DateTime(2000), endsAt);
  if (start == null || end == null) {
    return null;
  }
  final minutes = end.difference(start).inMinutes;
  return minutes > 0 ? minutes : null;
}
