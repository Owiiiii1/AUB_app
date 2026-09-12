import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/home/data/student_home_selectors.dart' as selectors;
import 'package:aub/features/home/state/teacher_home_state.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/schedule_kind.dart';

class TeacherHomeController extends ChangeNotifier {
  TeacherHomeController({
    required ScheduleRepository scheduleRepository,
    AcademyClock clock = const AcademyClock(),
  })  : _scheduleRepository = scheduleRepository,
        _clock = clock;

  final ScheduleRepository _scheduleRepository;
  final AcademyClock _clock;

  TeacherHomeState _state = const TeacherHomeState.loading();

  TeacherHomeState get state => _state;

  Future<void> load() => _fetch();

  Future<void> retry() => _fetch();

  Future<void> _fetch() async {
    _state = const TeacherHomeState.loading();
    notifyListeners();
    try {
      final now = _clock.now();
      final week = await _scheduleRepository.load(kind: ScheduleKind.teacher);
      _state = TeacherHomeState(
        status: TeacherHomeStatus.loaded,
        week: week,
        nextLesson: selectors.findNextLesson(week, now),
        todayLessons: selectors.todaysLessons(week, now),
        weekLessons: selectors.weekLessons(week),
        now: now,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = TeacherHomeState(
        status: TeacherHomeStatus.error,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const TeacherHomeState(
        status: TeacherHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const TeacherHomeState(
        status: TeacherHomeStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
