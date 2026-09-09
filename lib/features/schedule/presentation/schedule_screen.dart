import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/presentation/widgets/schedule_widgets.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/features/schedule/state/schedule_state.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({
    super.key,
    required this.controller,
    this.childName,
  });

  final ScheduleController controller;
  final String? childName;

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
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
    final title = switch (widget.controller.kind) {
      ScheduleKind.teacher => AppStrings.mySchedule,
      ScheduleKind.child => AppStrings.scheduleOf(widget.childName ?? ''),
      ScheduleKind.student => AppStrings.schedule,
    };

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: !_localeReady
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: widget.controller,
              builder: (context, _) {
                final state = widget.controller.state;
                return switch (state.status) {
                  ScheduleStatus.loading => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ScheduleStatus.error => _MessageState(
                      message: state.errorMessage ?? AppStrings.serverError,
                      onRetry: widget.controller.retry,
                    ),
                  ScheduleStatus.unpublished => _buildWeek(
                      state.view,
                      banner: AppStrings.unpublishedWeek,
                    ),
                  ScheduleStatus.loaded => _buildLoaded(state.view),
                };
              },
            ),
    );
  }

  Widget _buildLoaded(ScheduleWeekView? view) {
    if (view == null) {
      return _MessageState(
        message: AppStrings.serverError,
        onRetry: widget.controller.retry,
      );
    }
    if (view.emptyReason == ScheduleEmptyReason.noClass) {
      return _WeekScaffold(
        view: view,
        controller: widget.controller,
        child: const Padding(
          padding: EdgeInsets.all(24),
          child: Text(AppStrings.noClassSchedule, textAlign: TextAlign.center),
        ),
      );
    }
    return _buildWeek(
      view,
      banner: view.emptyReason == ScheduleEmptyReason.noLessons
          ? AppStrings.noLessonsThisWeek
          : null,
    );
  }

  Widget _buildWeek(ScheduleWeekView? view, {String? banner}) {
    if (view == null) {
      return _MessageState(
        message: AppStrings.unpublishedWeek,
        onRetry: widget.controller.retry,
      );
    }
    return _WeekScaffold(
      view: view,
      controller: widget.controller,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (banner != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(banner, textAlign: TextAlign.center),
            ),
          ...view.days.map((day) => ScheduleDaySection(day: day)),
        ],
      ),
    );
  }
}

class _WeekScaffold extends StatelessWidget {
  const _WeekScaffold({
    required this.view,
    required this.controller,
    required this.child,
  });

  final ScheduleWeekView view;
  final ScheduleController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ScheduleWeekHeader(
          startsOn: view.week.startsOn,
          endsOn: view.week.endsOn,
          onPrevious: controller.loadPrevious,
          onNext: controller.loadNext,
          onToday: controller.loadToday,
        ),
        Expanded(child: child),
      ],
    );
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}
