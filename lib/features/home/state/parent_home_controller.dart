import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/home/state/parent_home_state.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/schedule_kind.dart';

class ParentHomeController extends ChangeNotifier {
  ParentHomeController({
    required this.children,
    required ScheduleRepository scheduleRepository,
    required AttendanceHistoryRepository attendanceHistoryRepository,
    AcademyClock clock = const AcademyClock(),
  })  : _scheduleRepository = scheduleRepository,
        _historyRepository = attendanceHistoryRepository,
        _clock = clock;

  final List<ParentChild> children;
  final ScheduleRepository _scheduleRepository;
  final AttendanceHistoryRepository _historyRepository;
  final AcademyClock _clock;

  ParentHomeState _state = const ParentHomeState.loading();

  ParentHomeState get state => _state;

  Future<void> load() => _fetch();

  Future<void> retry() => _fetch();

  Future<void> _fetch() async {
    _state = const ParentHomeState.loading();
    notifyListeners();
    if (children.isEmpty) {
      _state = ParentHomeState(
        status: ParentHomeStatus.loaded,
        now: _clock.now(),
      );
      notifyListeners();
      return;
    }

    try {
      final now = _clock.now();
      final dashboards = await Future.wait(
        children.map((child) => _loadChild(child, now)),
      );
      final upcoming = <ChildUpcoming>[];
      for (final dashboard in dashboards) {
        for (final item in findUpcomingLessons(dashboard.week, now)) {
          upcoming.add(
            ChildUpcoming(
              child: dashboard.child,
              day: item.day,
              lesson: item.lesson,
            ),
          );
        }
      }
      upcoming.sort((a, b) {
        final startA = academyLessonStart(a.day.date, a.lesson.startsAt);
        final startB = academyLessonStart(b.day.date, b.lesson.startsAt);
        if (startA == null && startB == null) {
          return 0;
        }
        if (startA == null) {
          return 1;
        }
        if (startB == null) {
          return -1;
        }
        return startA.compareTo(startB);
      });
      _state = ParentHomeState(
        status: ParentHomeStatus.loaded,
        dashboards: dashboards,
        upcoming: upcoming.take(6).toList(growable: false),
        now: now,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = ParentHomeState(
        status: ParentHomeStatus.error,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const ParentHomeState(
        status: ParentHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const ParentHomeState(
        status: ParentHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }

  Future<ChildDashboard> _loadChild(ParentChild child, DateTime now) async {
    try {
      final week = await _scheduleRepository.load(
        kind: ScheduleKind.child,
        studentId: child.id,
      );
      final history = await _historyRepository.loadChildAttendance(
        studentId: child.id,
      );
      return ChildDashboard(
        child: child,
        week: week,
        history: history,
        nextLesson: findNextLesson(week, now),
        todayLessons: todaysLessons(week, now),
      );
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        rethrow;
      }
      return ChildDashboard(
        child: child,
        errorMessage: AuthMessages.forException(error),
      );
    } on FormatException {
      return ChildDashboard(
        child: child,
        errorMessage: AppStrings.serverError,
      );
    } catch (_) {
      return ChildDashboard(
        child: child,
        errorMessage: AppStrings.serverError,
      );
    }
  }
}
