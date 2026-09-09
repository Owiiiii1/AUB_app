import 'package:aub/features/attendance/models/attendance_models.dart';

enum AttendanceLoadStatus { loading, loaded, error }

class AttendanceState {
  const AttendanceState({
    required this.status,
    this.roster,
    this.draft = const {},
    this.saving = false,
    this.errorMessage,
    this.saveMessage,
  });

  const AttendanceState.loading()
      : this(status: AttendanceLoadStatus.loading);

  final AttendanceLoadStatus status;
  final AttendanceRoster? roster;
  final Map<int, AttendanceStatus?> draft;
  final bool saving;
  final String? errorMessage;
  final String? saveMessage;
}
