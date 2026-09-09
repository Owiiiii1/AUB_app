import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';

class AttendanceRepository {
  AttendanceRepository({required AttendanceApi api}) : _api = api;

  final AttendanceApi _api;

  Future<AttendanceRoster> load(int lessonId) {
    return _api.show(lessonId);
  }

  Future<AttendanceRoster> save({
    required int lessonId,
    required List<AttendanceWrite> attendance,
  }) {
    return _api.save(lessonId: lessonId, attendance: attendance);
  }
}
