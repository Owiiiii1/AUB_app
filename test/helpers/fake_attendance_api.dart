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
  Object? throwOnLoad;
  Object? throwOnSave;
  List<AttendanceWrite>? lastSave;
  int loads = 0;
  int saves = 0;

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
}
