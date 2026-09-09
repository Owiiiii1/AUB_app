import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';

class AttendanceHistoryRepository {
  AttendanceHistoryRepository({required AttendanceApi api}) : _api = api;

  final AttendanceApi _api;
  final Map<String, AttendanceHistory> _cache = {};

  Future<AttendanceHistory> loadStudentAttendance({String? month}) {
    return _load(studentId: null, month: month);
  }

  Future<AttendanceHistory> loadChildAttendance({
    required int studentId,
    String? month,
  }) {
    return _load(studentId: studentId, month: month);
  }

  Future<AttendanceHistory> _load({
    required int? studentId,
    String? month,
  }) async {
    final cacheKey = _key(studentId, month);
    final cached = _cache[cacheKey];
    if (cached != null) {
      return cached;
    }

    final history = studentId == null
        ? await _api.loadStudentAttendance(month: month)
        : await _api.loadChildAttendance(studentId: studentId, month: month);

    _cache[_key(studentId, history.period.month)] = history;
    if (month == null) {
      _cache[cacheKey] = history;
    }
    return history;
  }

  String _key(int? studentId, String? month) {
    final who = studentId == null ? 'self' : '$studentId';
    final when = month ?? 'current';
    return '$who|$when';
  }
}
