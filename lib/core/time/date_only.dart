DateTime parseDateOnly(String value) {
  final parts = value.split('-');
  if (parts.length != 3) {
    throw const FormatException('Invalid date.');
  }
  return DateTime(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

String formatDateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}

String formatYearMonth(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  return '${value.year}-$month';
}

String shiftYearMonth(String month, int delta) {
  final parts = month.split('-');
  if (parts.length != 2) {
    throw const FormatException('Invalid month.');
  }
  final shifted = DateTime(int.parse(parts[0]), int.parse(parts[1]) + delta);
  return formatYearMonth(shifted);
}

bool isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
