import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';

class FakeAttendanceApi extends AttendanceApi {
  FakeAttendanceApi()
      : super(
          ApiClient(
            config: const AppConfig(
              apiBaseUrl: 'https://aub.owlsolutions.net/api/v1',
            ),
          ),
        );

  AttendanceRoster? roster;
  AttendanceHistory? history;
  final Map<int, AttendanceHistory> childHistories = {};
  Object? throwOnLoad;
  Object? throwOnSave;
  Object? throwOnHistory;
  List<AttendanceWrite>? lastSave;
  String? lastHistoryMonth;
  int? lastHistoryStudentId;
  int loads = 0;
  int saves = 0;
  int historyLoads = 0;

  @override
  Future<AttendanceRoster> show(int lessonId) async {
    loads += 1;
    if (throwOnLoad != null) {
      throw throwOnLoad!;
    }
    return roster!;
  }

  @override
  Future<AttendanceRoster> save({
    required int lessonId,
    required List<AttendanceWrite> attendance,
  }) async {
    saves += 1;
    lastSave = attendance;
    if (throwOnSave != null) {
      throw throwOnSave!;
    }
    return roster!;
  }

  @override
  Future<AttendanceHistory> loadStudentAttendance({String? month}) async {
    historyLoads += 1;
    lastHistoryMonth = month;
    lastHistoryStudentId = null;
    if (throwOnHistory != null) {
      throw throwOnHistory!;
    }
    return history!;
  }

  @override
  Future<AttendanceHistory> loadChildAttendance({
    required int studentId,
    String? month,
  }) async {
    historyLoads += 1;
    lastHistoryMonth = month;
    lastHistoryStudentId = studentId;
    if (throwOnHistory != null) {
      throw throwOnHistory!;
    }
    return childHistories[studentId] ?? history!;
  }
}
