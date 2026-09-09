import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';

class AttendanceWrite {
  const AttendanceWrite({required this.studentId, this.status});

  final int studentId;
  final AttendanceStatus? status;

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'status': status?.apiValue,
    };
  }
}

class AttendanceApi {
  AttendanceApi(this._client);

  final ApiClient _client;

  Future<AttendanceRoster> show(int lessonId) async {
    final data = await _client.get('/teacher/lessons/$lessonId/attendance');
    return AttendanceRoster.fromJson(data);
  }

  Future<AttendanceRoster> save({
    required int lessonId,
    required List<AttendanceWrite> attendance,
  }) async {
    final data = await _client.put(
      '/teacher/lessons/$lessonId/attendance',
      body: {
        'attendance': attendance.map((row) => row.toJson()).toList(),
      },
    );
    return AttendanceRoster.fromJson(data);
  }
}
