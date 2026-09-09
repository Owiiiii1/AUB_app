import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

class ScheduleRepository {
  ScheduleRepository({required ScheduleApi api}) : _api = api;

  final ScheduleApi _api;
  final Map<String, ScheduleWeekView> _cache = {};

  Future<ScheduleWeekView> load({
    int? studentId,
    DateTime? week,
  }) async {
    final cacheKey = _key(studentId, week);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final view = studentId == null
        ? await _api.studentWeek(week: week)
        : await _api.childWeek(studentId: studentId, week: week);
    _cache[_key(studentId, view.week.startsOn)] = view;
    if (week != null) {
      _cache[cacheKey] = view;
    }
    return view;
  }

  String _key(int? studentId, DateTime? week) {
    final who = studentId?.toString() ?? 'self';
    final when = week == null ? 'current' : formatDateOnly(week);
    return '$who|$when';
  }
}
