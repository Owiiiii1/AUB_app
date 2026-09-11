import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/presentation/student_attendance_view.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/attendance/state/attendance_history_state.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({
    super.key,
    required this.controller,
    this.childName,
    this.embedded = false,
    this.studentVisuals = false,
  });

  final AttendanceHistoryController controller;
  final String? childName;
  final bool embedded;
  final bool studentVisuals;

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('it').then((_) {
      if (mounted) {
        setState(() => _localeReady = true);
      }
    });
    widget.controller.loadCurrent();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.childName == null
        ? AppStrings.attendance
        : AppStrings.attendanceOf(widget.childName!);

    final body = !_localeReady
        ? const AubLoading()
        : ListenableBuilder(
            listenable: widget.controller,
            builder: (context, _) {
              final state = widget.controller.state;
              return switch (state.status) {
                AttendanceHistoryStatus.loading => const AubLoading(),
                AttendanceHistoryStatus.error => AubErrorState(
                    message: state.errorMessage ?? AppStrings.serverError,
                    onRetry: widget.controller.retry,
                  ),
                AttendanceHistoryStatus.empty => _scaffold(
                    history: state.history,
                    child: widget.studentVisuals
                        ? const AubEmptyState(
                            message: AppStrings.noAttendanceThisMonth,
                          )
                        : const Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              AppStrings.noAttendanceThisMonth,
                              textAlign: TextAlign.center,
                            ),
                          ),
                  ),
                AttendanceHistoryStatus.loaded => _scaffold(
                    history: state.history,
                    child: widget.studentVisuals
                        ? StudentAttendanceRecords(history: state.history!)
                        : _HistoryBody(history: state.history!),
                  ),
              };
            },
          );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: body,
    );
  }

  Widget _scaffold({required AttendanceHistory? history, required Widget child}) {
    if (widget.studentVisuals) {
      return StudentAttendanceView(
        history: history,
        controller: widget.controller,
        child: child,
      );
    }
    return _HistoryScaffold(
      history: history,
      controller: widget.controller,
      child: child,
    );
  }
}

class _HistoryScaffold extends StatelessWidget {
  const _HistoryScaffold({
    required this.history,
    required this.controller,
    required this.child,
  });

  final AttendanceHistory? history;
  final AttendanceHistoryController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (history != null)
          _MonthHeader(
            month: history!.period.month,
            onPrevious: controller.loadPrevious,
            onNext: controller.loadNext,
            onCurrent: controller.loadCurrent,
          ),
        if (history != null) _SummaryRow(summary: history!.summary),
        Expanded(child: child),
      ],
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.onPrevious,
    required this.onNext,
    required this.onCurrent,
  });

  final String month;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onCurrent;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      int.parse(month.split('-')[0]),
      int.parse(month.split('-')[1]),
    );
    var label = DateFormat('MMMM y', 'it').format(date);
    if (label.isNotEmpty) {
      label = '${label[0].toUpperCase()}${label.substring(1)}';
    }

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        TextButton(
          onPressed: onCurrent,
          child: const Text(AppStrings.thisMonth),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _SummaryChip(label: AppStrings.totalLabel, value: summary.marked),
          _SummaryChip(label: AppStrings.presentPlural, value: summary.present),
          _SummaryChip(label: AppStrings.absentPlural, value: summary.absent),
          _SummaryChip(label: AppStrings.excusedPlural, value: summary.excused),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            children: [
              Text(
                '$value',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.history});

  final AttendanceHistory history;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<AttendanceHistoryRecord>>{};
    for (final record in history.records) {
      groups.putIfAbsent(record.date, () => []).add(record);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              _dateLabel(entry.key),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          for (final record in entry.value) _RecordCard(record: record),
        ],
      ],
    );
  }

  String _dateLabel(String date) {
    final parsed = parseDateOnly(date);
    var label = DateFormat('d MMMM', 'it').format(parsed);
    if (label.isNotEmpty) {
      label = '${label[0].toUpperCase()}${label.substring(1)}';
    }
    return label;
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final AttendanceHistoryRecord record;

  @override
  Widget build(BuildContext context) {
    final room = record.location?.room?.name;
    final teacher = record.teacher?.displayName;
    final subtitleParts = <String>[
      if (teacher != null && teacher.isNotEmpty) teacher,
      if (room != null && room.isNotEmpty) room,
    ];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${record.startsAt} – ${record.endsAt}'),
            Text(
              record.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            _StatusBadge(status: record.status),
            if (subtitleParts.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(subtitleParts.join(' · ')),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final AttendanceStatus status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      AttendanceStatus.present => (AppStrings.present, scheme.primaryContainer),
      AttendanceStatus.absent => (AppStrings.absent, scheme.errorContainer),
      AttendanceStatus.excused => (
          AppStrings.excused,
          scheme.tertiaryContainer,
        ),
    };

    return Chip(
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: color,
    );
  }
}
