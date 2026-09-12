import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_state.dart';

class ScheduleController extends ChangeNotifier {
  ScheduleController({
    required ScheduleRepository repository,
    this.kind = ScheduleKind.student,
    int? studentId,
    AcademyClock clock = const AcademyClock(),
  })  : _repository = repository,
        _studentId = studentId,
        _clock = clock;

  final ScheduleRepository _repository;
  final ScheduleKind kind;
  final AcademyClock _clock;
  int? _studentId;
  DateTime? _requestedWeek;
  int _loadGeneration = 0;
  int? lastRequestedStudentId;
  ScheduleKind? lastRequestedKind;
  ScheduleState _state = const ScheduleState.loading();

  int? get studentId => _studentId;

  ScheduleState get state => _state;

  Future<void> bindStudent(int? id) {
    if (_studentId == id) {
      return Future.value();
    }
    _studentId = id;
    _requestedWeek = null;
    return loadCurrent();
  }

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

  Future<void> loadToday() => load(week: _clock.now());

  Future<void> retry() => _fetch(_requestedWeek);

  Future<void> _fetch(DateTime? week) async {
    final generation = ++_loadGeneration;
    lastRequestedStudentId = studentId;
    lastRequestedKind = kind;
    final previous = _state.view;
    _state = const ScheduleState.loading();
    notifyListeners();
    try {
      if (kind == ScheduleKind.child && studentId == null) {
        if (generation != _loadGeneration) {
          return;
        }
        _state = const ScheduleState(status: ScheduleStatus.loaded);
        notifyListeners();
        return;
      }
      final view = await _repository.load(
        kind: kind,
        studentId: studentId,
        week: week,
      );
      if (generation != _loadGeneration) {
        return;
      }
      final status = view.emptyReason == ScheduleEmptyReason.unpublished
          ? ScheduleStatus.unpublished
          : ScheduleStatus.loaded;
      _state = ScheduleState(status: status, view: view);
      notifyListeners();
    } on ApiException catch (error) {
      if (generation != _loadGeneration) {
        return;
      }
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
      if (generation != _loadGeneration) {
        return;
      }
      _state = const ScheduleState(
        status: ScheduleStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      if (generation != _loadGeneration) {
        return;
      }
      _state = const ScheduleState(
        status: ScheduleStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
