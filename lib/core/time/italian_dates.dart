import 'package:intl/intl.dart';

String capitalizeIt(String value) {
  if (value.isEmpty) {
    return value;
  }
  return '${value[0].toUpperCase()}${value.substring(1)}';
}

String italianWeekdayDate(DateTime date) {
  return capitalizeIt(DateFormat("EEEE d MMMM", 'it').format(date));
}

String italianWeekdayDateYear(DateTime date) {
  return capitalizeIt(DateFormat("EEEE d MMMM y", 'it').format(date));
}

String italianMonthYear(DateTime date) {
  return capitalizeIt(DateFormat('MMMM y', 'it').format(date));
}

String italianWeekRange(DateTime startsOn, DateTime endsOn) {
  final startDay = DateFormat('d', 'it').format(startsOn);
  final endLabel = DateFormat('d MMMM y', 'it').format(endsOn);
  return '$startDay – $endLabel';
}

String italianWeekdayShort(DateTime date) {
  return DateFormat('E', 'it').format(date).toUpperCase();
}
