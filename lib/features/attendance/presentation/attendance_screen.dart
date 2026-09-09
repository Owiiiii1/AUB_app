import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/attendance/presentation/widgets/attendance_widgets.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/attendance/state/attendance_state.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key, required this.controller});

  final AttendanceController controller;

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  Future<void> _onPopInvoked(bool didPop, Object? result) async {
    if (didPop) {
      return;
    }
    final leave = await confirmDiscardAttendance(context);
    if (leave && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final controller = widget.controller;
        final state = controller.state;
        final blockPop = controller.isDirty &&
            (state.roster?.editable ?? false) &&
            state.status == AttendanceLoadStatus.loaded;

        return PopScope(
          canPop: !blockPop,
          onPopInvokedWithResult: _onPopInvoked,
          child: Scaffold(
            appBar: AppBar(
              title: Text(state.roster?.lesson.title ?? AppStrings.attendance),
            ),
            body: switch (state.status) {
              AttendanceLoadStatus.loading => const Center(
                  child: CircularProgressIndicator(),
                ),
              AttendanceLoadStatus.error => _ErrorBody(
                  message: state.errorMessage ?? AppStrings.serverError,
                  onRetry: controller.retry,
                ),
              AttendanceLoadStatus.loaded => _RosterBody(controller: controller),
            },
          ),
        );
      },
    );
  }
}

class _RosterBody extends StatelessWidget {
  const _RosterBody({required this.controller});

  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final roster = state.roster;
    if (roster == null) {
      return _ErrorBody(
        message: AppStrings.serverError,
        onRetry: controller.retry,
      );
    }
    final editable = roster.editable && !state.saving;
    final cancelled = !roster.editable;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              AttendanceHeader(lesson: roster.lesson, readOnly: cancelled),
              if (state.errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (state.saveMessage != null) ...[
                const SizedBox(height: 8),
                Text(
                  state.saveMessage!,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
              const SizedBox(height: 16),
              if (editable)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: controller.markAllPresent,
                    child: const Text(AppStrings.markAllPresent),
                  ),
                ),
              const SizedBox(height: 8),
              ...roster.students.map((student) {
                return AttendanceStudentRow(
                  student: student,
                  selected: controller.statusOf(student),
                  enabled: editable,
                  onChanged: (status) {
                    final current = controller.statusOf(student);
                    controller.mark(
                      student.id,
                      current == status ? null : status,
                    );
                  },
                );
              }),
            ],
          ),
        ),
        if (!cancelled)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: AttendanceSaveBar(controller: controller),
              ),
            ),
          ),
      ],
    );
  }
}

class _ErrorBody extends StatelessWidget {
  const _ErrorBody({required this.message, required this.onRetry});

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
