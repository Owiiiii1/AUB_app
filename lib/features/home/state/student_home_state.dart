import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

enum StudentHomeStatus { loading, loaded, error }

class StudentHomeState {
  const StudentHomeState({
    required this.status,
    this.week,
    this.history,
    this.nextLesson,
    this.todayLessons = const [],
    this.now,
    this.errorMessage,
  });

  const StudentHomeState.loading() : this(status: StudentHomeStatus.loading);

  final StudentHomeStatus status;
  final ScheduleWeekView? week;
  final AttendanceHistory? history;
  final UpcomingLesson? nextLesson;
  final List<({ScheduleDay day, ScheduleLesson lesson})> todayLessons;
  final DateTime? now;
  final String? errorMessage;
}
