import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

class FakeScheduleApi extends ScheduleApi {
  FakeScheduleApi()
      : super(
          ApiClient(
            config: const AppConfig(apiBaseUrl: 'https://aub.owlsolutions.net/api/v1'),
          ),
        );

  final Map<String, ScheduleWeekView> responses = {};
  Object? throwError;
  DateTime? lastWeek;
  int? lastStudentId;
  int studentLoads = 0;
  int childLoads = 0;
  int teacherLoads = 0;

  @override
  Future<ScheduleWeekView> studentWeek({DateTime? week}) async {
    studentLoads += 1;
    lastWeek = week;
    lastStudentId = null;
    if (throwError != null) {
      throw throwError!;
    }
    return _viewFor(week);
  }

  @override
  Future<ScheduleWeekView> childWeek({
    required int studentId,
    DateTime? week,
  }) async {
    childLoads += 1;
    lastWeek = week;
    lastStudentId = studentId;
    if (throwError != null) {
      throw throwError!;
    }
    return _viewFor(week);
  }

  @override
  Future<ScheduleWeekView> teacherWeek({DateTime? week}) async {
    teacherLoads += 1;
    lastWeek = week;
    lastStudentId = null;
    if (throwError != null) {
      throw throwError!;
    }
    return _viewFor(week);
  }

  ScheduleWeekView _viewFor(DateTime? week) {
    final key = week == null
        ? 'current'
        : '${week.year}-${week.month.toString().padLeft(2, '0')}-${week.day.toString().padLeft(2, '0')}';
    return responses[key] ?? responses['current']!;
  }
}
