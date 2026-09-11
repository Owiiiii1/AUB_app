import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/home/state/student_home_state.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/schedule_kind.dart';

class StudentHomeController extends ChangeNotifier {
  StudentHomeController({
    required ScheduleRepository scheduleRepository,
    required AttendanceHistoryRepository attendanceHistoryRepository,
    AcademyClock clock = const AcademyClock(),
  })  : _scheduleRepository = scheduleRepository,
        _historyRepository = attendanceHistoryRepository,
        _clock = clock;

  final ScheduleRepository _scheduleRepository;
  final AttendanceHistoryRepository _historyRepository;
  final AcademyClock _clock;

  StudentHomeState _state = const StudentHomeState.loading();

  StudentHomeState get state => _state;

  Future<void> load() => _fetch();

  Future<void> retry() => _fetch();

  Future<void> _fetch() async {
    _state = const StudentHomeState.loading();
    notifyListeners();
    try {
      final now = _clock.now();
      final weekFuture = _scheduleRepository.load(kind: ScheduleKind.student);
      final historyFuture = _historyRepository.loadStudentAttendance();
      final week = await weekFuture;
      final history = await historyFuture;
      _state = StudentHomeState(
        status: StudentHomeStatus.loaded,
        week: week,
        history: history,
        nextLesson: findNextLesson(week, now),
        todayLessons: todaysLessons(week, now),
        now: now,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = StudentHomeState(
        status: StudentHomeStatus.error,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const StudentHomeState(
        status: StudentHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const StudentHomeState(
        status: StudentHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
