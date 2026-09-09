import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

class ScheduleApi {
  ScheduleApi(this._client);

  final ApiClient _client;

  Future<ScheduleWeekView> studentWeek({DateTime? week}) {
    return _load('/schedule', week);
  }

  Future<ScheduleWeekView> childWeek({
    required int studentId,
    DateTime? week,
  }) {
    return _load('/children/$studentId/schedule', week);
  }

  Future<ScheduleWeekView> teacherWeek({DateTime? week}) {
    return _load('/teacher/schedule', week);
  }

  Future<ScheduleWeekView> _load(String path, DateTime? week) async {
    final data = await _client.get(
      path,
      query: week == null ? null : {'week': formatDateOnly(week)},
    );
    return ScheduleWeekView.fromJson(data);
  }
}
