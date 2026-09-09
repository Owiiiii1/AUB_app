import 'package:aub/features/schedule/models/schedule_week.dart';

enum ScheduleStatus {
  loading,
  loaded,
  unpublished,
  error,
}

class ScheduleState {
  const ScheduleState({
    required this.status,
    this.view,
    this.errorMessage,
  });

  const ScheduleState.loading() : this(status: ScheduleStatus.loading);

  final ScheduleStatus status;
  final ScheduleWeekView? view;
  final String? errorMessage;
}
