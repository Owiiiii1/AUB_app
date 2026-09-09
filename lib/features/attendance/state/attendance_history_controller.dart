import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/state/attendance_history_state.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';

class AttendanceHistoryController extends ChangeNotifier {
  AttendanceHistoryController({
    required AttendanceHistoryRepository repository,
    this.studentId,
  }) : _repository = repository;

  final AttendanceHistoryRepository _repository;
  final int? studentId;
  String? _requestedMonth;
  int? lastRequestedStudentId;
  AttendanceHistoryState _state = const AttendanceHistoryState.loading();

  AttendanceHistoryState get state => _state;

  Future<void> load({String? month}) {
    _requestedMonth = month;
    return _fetch(month);
  }

  Future<void> loadCurrent() => load();

  Future<void> loadPrevious() {
    final month = _state.history?.period.month;
    if (month == null) {
      return Future.value();
    }
    return load(month: shiftYearMonth(month, -1));
  }

  Future<void> loadNext() {
    final month = _state.history?.period.month;
    if (month == null) {
      return Future.value();
    }
    return load(month: shiftYearMonth(month, 1));
  }

  Future<void> retry() => _fetch(_requestedMonth);

  Future<void> _fetch(String? month) async {
    lastRequestedStudentId = studentId;
    final previous = _state.history;
    _state = const AttendanceHistoryState.loading();
    notifyListeners();
    try {
      final history = studentId == null
          ? await _repository.loadStudentAttendance(month: month)
          : await _repository.loadChildAttendance(
              studentId: studentId!,
              month: month,
            );
      _state = AttendanceHistoryState(
        status: history.records.isEmpty
            ? AttendanceHistoryStatus.empty
            : AttendanceHistoryStatus.loaded,
        history: history,
      );
      notifyListeners();
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        return;
      }
      _state = AttendanceHistoryState(
        status: AttendanceHistoryStatus.error,
        history: previous,
        errorMessage: AuthMessages.forException(error),
      );
      notifyListeners();
    } on FormatException {
      _state = const AttendanceHistoryState(
        status: AttendanceHistoryStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    } catch (_) {
      _state = const AttendanceHistoryState(
        status: AttendanceHistoryStatus.error,
        errorMessage: AppStrings.serverError,
      );
      notifyListeners();
    }
  }
}
