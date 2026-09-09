import 'package:aub/features/attendance/models/attendance_models.dart';

enum AttendanceHistoryStatus { loading, loaded, empty, error }

class AttendanceHistoryState {
  const AttendanceHistoryState({
    required this.status,
    this.history,
    this.errorMessage,
  });

  const AttendanceHistoryState.loading()
      : this(status: AttendanceHistoryStatus.loading);

  final AttendanceHistoryStatus status;
  final AttendanceHistory? history;
  final String? errorMessage;
}
