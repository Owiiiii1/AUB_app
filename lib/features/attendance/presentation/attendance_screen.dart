import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/attendance/presentation/widgets/attendance_widgets.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/attendance/state/attendance_state.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';

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
            backgroundColor: AubColors.surfaceIvory,
            appBar: AppBar(
              title: Text(state.roster?.lesson.title ?? AppStrings.attendance),
            ),
            body: switch (state.status) {
              AttendanceLoadStatus.loading => const AubLoading(),
              AttendanceLoadStatus.error => AubErrorState(
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
      return AubErrorState(
        message: AppStrings.serverError,
        onRetry: controller.retry,
      );
    }
    final editable = roster.editable && !state.saving;
    final cancelled = !roster.editable;
    final students = roster.students;

    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AubSpacing.margin,
                  AubSpacing.sm,
                  AubSpacing.margin,
                  0,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AttendanceHeader(
                        lesson: roster.lesson,
                        readOnly: cancelled,
                      ),
                      if (state.errorMessage != null) ...[
                        const SizedBox(height: AubSpacing.sm),
                        Text(
                          state.errorMessage!,
                          style: AubText.bodySm.copyWith(color: AubColors.alert),
                        ),
                      ],
                      if (state.saveMessage != null) ...[
                        const SizedBox(height: AubSpacing.xs),
                        Text(
                          state.saveMessage!,
                          style: AubText.labelMd.copyWith(
                            color: AubColors.success,
                          ),
                        ),
                      ],
                      if (controller.isDirty && editable) ...[
                        const SizedBox(height: AubSpacing.xs),
                        Text(
                          AppStrings.draftUnsaved,
                          style: AubText.labelSm.copyWith(
                            color: AubColors.warning,
                          ),
                        ),
                      ],
                      const SizedBox(height: AubSpacing.md),
                      Row(
                        children: [
                          Text(
                            AppStrings.pupilsCount(students.length).toUpperCase(),
                            style: AubText.labelCaps,
                          ),
                          const Spacer(),
                          if (editable)
                            TextButton(
                              onPressed: controller.markAllPresent,
                              child: const Text(AppStrings.markAllPresent),
                            ),
                        ],
                      ),
                      const SizedBox(height: AubSpacing.xs),
                    ],
                  ),
                ),
              ),
              if (students.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: AubEmptyState(message: AppStrings.noStudentsInLesson),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AubSpacing.margin,
                    0,
                    AubSpacing.margin,
                    AubSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final student = students[index];
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
                      },
                      childCount: students.length,
                    ),
                  ),
                ),
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
