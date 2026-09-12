import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

enum TeacherHomeStatus { loading, loaded, error }

class TeacherHomeState {
  const TeacherHomeState({
    required this.status,
    this.week,
    this.nextLesson,
    this.todayLessons = const [],
    this.weekLessons = const [],
    this.now,
    this.errorMessage,
  });

  const TeacherHomeState.loading() : this(status: TeacherHomeStatus.loading);

  final TeacherHomeStatus status;
  final ScheduleWeekView? week;
  final UpcomingLesson? nextLesson;
  final List<({ScheduleDay day, ScheduleLesson lesson})> todayLessons;
  final List<({ScheduleDay day, ScheduleLesson lesson})> weekLessons;
  final DateTime? now;
  final String? errorMessage;
}
