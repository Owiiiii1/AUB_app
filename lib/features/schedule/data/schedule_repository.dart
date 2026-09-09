import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/schedule_kind.dart';

class ScheduleRepository {
  ScheduleRepository({required ScheduleApi api}) : _api = api;

  final ScheduleApi _api;
  final Map<String, ScheduleWeekView> _cache = {};

  Future<ScheduleWeekView> load({
    ScheduleKind kind = ScheduleKind.student,
    int? studentId,
    DateTime? week,
  }) async {
    final cacheKey = _key(kind, studentId, week);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final view = switch (kind) {
      ScheduleKind.student => await _api.studentWeek(week: week),
      ScheduleKind.child => await _api.childWeek(studentId: studentId!, week: week),
      ScheduleKind.teacher => await _api.teacherWeek(week: week),
    };
    _cache[_key(kind, studentId, view.week.startsOn)] = view;
    if (week != null) {
      _cache[cacheKey] = view;
    }
    return view;
  }

  String _key(ScheduleKind kind, int? studentId, DateTime? week) {
    final who = switch (kind) {
      ScheduleKind.student => 'self',
      ScheduleKind.child => '${studentId ?? 'child'}',
      ScheduleKind.teacher => 'teacher',
    };
    final when = week == null ? 'current' : formatDateOnly(week);
    return '$who|$when';
  }
}
