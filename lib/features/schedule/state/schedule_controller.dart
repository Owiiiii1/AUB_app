import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/state/schedule_state.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController({
    required ScheduleRepository repository,
    this.studentId,
  }) : _repository = repository;

  final ScheduleRepository _repository;
  final int? studentId;
  DateTime? _requestedWeek;
  int? lastRequestedStudentId;
  ScheduleState _state = const ScheduleState.loading();

  ScheduleState get state => _state;

  Future<void> load({DateTime? week}) {
    _requestedWeek = week;
    return _fetch(week);
  }

  Future<void> loadCurrent() => load();

  Future<void> loadPrevious() {
    final start = _state.view?.week.startsOn;
    if (start == null) {
      return Future.value();
    }
    return load(week: start.subtract(const Duration(days: 7)));
  }

  Future<void> loadNext() {
    final start = _state.view?.week.startsOn;
    if (start == null) {
      return Future.value();
    }
    return load(week: start.add(const Duration(days: 7)));
  }

  Future<void> loadToday() => load(week: DateTime.now());

  Future<void> retry() => _fetch(_requestedWeek);

  Future<void> _fetch(DateTime? week) async {
    lastRequestedStudentId = studentId;
    final previous = _state.view;
    _state = const ScheduleState.loading();
    notifyListeners();
    try {
      final view = await _repository.load(studentId: studentId, week: week);
      final status = view.emptyReason == ScheduleEmptyReason.unpublished
          ? ScheduleStatus.unpublished
          : ScheduleStatus.loaded;
      _state = ScheduleState(status: status, view: view);
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = ScheduleState(
        status: ScheduleStatus.error,
        view: previous,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const ScheduleState(
        status: ScheduleStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const ScheduleState(
        status: ScheduleStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
