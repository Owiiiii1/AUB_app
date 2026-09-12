import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

enum ParentHomeStatus { loading, loaded, error }

class ChildDashboard {
  const ChildDashboard({
    required this.child,
    this.week,
    this.history,
    this.nextLesson,
    this.todayLessons = const [],
    this.errorMessage,
  });

  final ParentChild child;
  final ScheduleWeekView? week;
  final AttendanceHistory? history;
  final UpcomingLesson? nextLesson;
  final List<({ScheduleDay day, ScheduleLesson lesson})> todayLessons;
  final String? errorMessage;
}

class ChildUpcoming {
  const ChildUpcoming({
    required this.child,
    required this.day,
    required this.lesson,
  });

  final ParentChild child;
  final ScheduleDay day;
  final ScheduleLesson lesson;
}

class ParentHomeState {
  const ParentHomeState({
    required this.status,
    this.dashboards = const [],
    this.upcoming = const [],
    this.now,
    this.errorMessage,
  });

  const ParentHomeState.loading() : this(status: ParentHomeStatus.loading);

  final ParentHomeStatus status;
  final List<ChildDashboard> dashboards;
  final List<ChildUpcoming> upcoming;
  final DateTime? now;
  final String? errorMessage;

  ChildDashboard? dashboardFor(int childId) {
    for (final dashboard in dashboards) {
      if (dashboard.child.id == childId) {
        return dashboard;
      }
    }
    return null;
  }
}
