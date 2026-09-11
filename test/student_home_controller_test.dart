import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/home/state/student_home_controller.dart';
import 'package:aub/features/home/state/student_home_state.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/fake_attendance_api.dart';
import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

void main() {
  test('next lesson skips cancelled and past lessons', () {
    final json = publishedScheduleJson();
    (json['days'] as List)[0]['lessons'] = [
      {
        'id': 1,
        'starts_at': '10:00',
        'ends_at': '11:00',
        'title': 'Mattina',
        'status': 'published',
      },
      {
        'id': 2,
        'starts_at': '16:00',
        'ends_at': '17:30',
        'title': 'Classica',
        'status': 'cancelled',
      },
      {
        'id': 3,
        'starts_at': '18:00',
        'ends_at': '19:00',
        'title': 'Repertorio',
        'status': 'moved',
      },
    ];
    final view = ScheduleWeekView.fromJson(json);
    final now = DateTime(2026, 9, 7, 15, 0);
    final next = findNextLesson(view, now);
    expect(next?.lesson.title, 'Repertorio');
    expect(todaysLessons(view, now).length, 3);
  });

  test('unpublished week has no next lesson', () {
    final view = ScheduleWeekView.fromJson(unpublishedScheduleJson());
    expect(findNextLesson(view, DateTime(2026, 9, 7, 10)), isNull);
    expect(todaysLessons(view, DateTime(2026, 9, 7, 10)), isEmpty);
  });

  test('home controller loads summary without treating unmarked as absent',
      () async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(publishedScheduleJson());
    final attendanceApi = FakeAttendanceApi()
      ..history = attendanceHistory(
        marked: 2,
        present: 2,
        absent: 0,
        excused: 0,
        records: [
          (attendanceHistoryJson()['records'] as List).first
              as Map<String, dynamic>,
        ],
      );
    final controller = StudentHomeController(
      scheduleRepository: ScheduleRepository(api: scheduleApi),
      attendanceHistoryRepository: AttendanceHistoryRepository(api: attendanceApi),
      clock: AcademyClock(now: () => DateTime(2026, 9, 7, 10)),
    );

    await controller.load();
    expect(controller.state.status, StudentHomeStatus.loaded);
    expect(controller.state.history?.summary.absent, 0);
    expect(controller.state.nextLesson?.lesson.title, 'Danza classica');
  });
}
