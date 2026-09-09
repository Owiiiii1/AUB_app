import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/state/attendance_state.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';

class AttendanceController extends ChangeNotifier {
  AttendanceController({
    required AttendanceRepository repository,
    required this.lessonId,
  }) : _repository = repository;

  final AttendanceRepository _repository;
  final int lessonId;
  AttendanceState _state = const AttendanceState.loading();

  AttendanceState get state => _state;

  bool get isDirty {
    final roster = _state.roster;
    if (roster == null) {
      return false;
    }
    for (final student in roster.students) {
      if (statusOf(student) != student.attendance?.status) {
        return true;
      }
    }
    return false;
  }

  bool get canSave =>
      (_state.roster?.editable ?? false) &&
      isDirty &&
      !_state.saving &&
      _state.status == AttendanceLoadStatus.loaded;

  AttendanceStatus? statusOf(AttendanceStudent student) {
    if (_state.draft.containsKey(student.id)) {
      return _state.draft[student.id];
    }
    return student.attendance?.status;
  }

  Future<void> load() async {
    _state = const AttendanceState.loading();
    notifyListeners();
    try {
      final roster = await _repository.load(lessonId);
      _state = AttendanceState(
        status: AttendanceLoadStatus.loaded,
        roster: roster,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = AttendanceState(
        status: AttendanceLoadStatus.error,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const AttendanceState(
        status: AttendanceLoadStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const AttendanceState(
        status: AttendanceLoadStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }

  void retry() => load();

  void mark(int studentId, AttendanceStatus? status) {
    final roster = _state.roster;
    if (roster == null || !roster.editable || _state.saving) {
      return;
    }
    final next = Map<int, AttendanceStatus?>.from(_state.draft);
    next[studentId] = status;
    _state = AttendanceState(
      status: _state.status,
      roster: roster,
      draft: next,
    );
    notifyListeners();
  }

  void markAllPresent() {
    final roster = _state.roster;
    if (roster == null || !roster.editable || _state.saving) {
      return;
    }
    final next = <int, AttendanceStatus?>{};
    for (final student in roster.students) {
      next[student.id] = AttendanceStatus.present;
    }
    _state = AttendanceState(
      status: _state.status,
      roster: roster,
      draft: next,
    );
    notifyListeners();
  }

  Future<void> save() async {
    final roster = _state.roster;
    if (roster == null || !canSave) {
      return;
    }
    final rows = <AttendanceWrite>[];
    for (final student in roster.students) {
      if (!_state.draft.containsKey(student.id)) {
        continue;
      }
      rows.add(
        AttendanceWrite(
          studentId: student.id,
          status: _state.draft[student.id],
        ),
      );
    }
    if (rows.isEmpty) {
      return;
    }

    final preservedDraft = Map<int, AttendanceStatus?>.from(_state.draft);
    _state = AttendanceState(
      status: _state.status,
      roster: roster,
      draft: preservedDraft,
      saving: true,
    );
    notifyListeners();

    try {
      final saved = await _repository.save(lessonId: lessonId, attendance: rows);
      _state = AttendanceState(
        status: AttendanceLoadStatus.loaded,
        roster: saved,
        saveMessage: AppStrings.attendanceSaved,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        _state = AttendanceState(
          status: AttendanceLoadStatus.loaded,
          roster: roster,
          draft: preservedDraft,
        );
        notifyListeners();
        return;
      }
      _state = AttendanceState(
        status: AttendanceLoadStatus.loaded,
        roster: roster,
        draft: preservedDraft,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = AttendanceState(
        status: AttendanceLoadStatus.loaded,
        roster: roster,
        draft: preservedDraft,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = AttendanceState(
        status: AttendanceLoadStatus.loaded,
        roster: roster,
        draft: preservedDraft,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
