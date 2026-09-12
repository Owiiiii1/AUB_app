import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/italian_dates.dart';
import 'package:aub/features/home/presentation/widgets/teacher_lesson_card.dart';
import 'package:aub/features/home/state/teacher_home_controller.dart';
import 'package:aub/features/home/state/teacher_home_state.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';

class TeacherPresenzeScreen extends StatelessWidget {
  const TeacherPresenzeScreen({
    super.key,
    required this.controller,
    this.onOpenAttendance,
  });

  final TeacherHomeController controller;
  final ValueChanged<ScheduleLesson>? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return switch (state.status) {
          TeacherHomeStatus.loading => const AubLoading(),
          TeacherHomeStatus.error => AubErrorState(
              message: state.errorMessage ?? AppStrings.serverError,
              onRetry: controller.retry,
            ),
          TeacherHomeStatus.loaded => _PresenzeLoaded(
              state: state,
              onOpenAttendance: onOpenAttendance,
            ),
        };
      },
    );
  }
}

class _PresenzeLoaded extends StatelessWidget {
  const _PresenzeLoaded({
    required this.state,
    this.onOpenAttendance,
  });

  final TeacherHomeState state;
  final ValueChanged<ScheduleLesson>? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final now = state.now ?? const AcademyClock().now();
    final unpublished =
        state.week?.emptyReason == ScheduleEmptyReason.unpublished;
    final days = state.week?.days ?? const <ScheduleDay>[];
    final hasLessons = state.weekLessons.isNotEmpty;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        Text(
          AppStrings.attendance.toUpperCase(),
          style: AubText.headlineLg,
        ),
        const SizedBox(height: AubSpacing.md),
        if (unpublished)
          const AubCard(
            child: AubEmptyState(message: AppStrings.unpublishedWeek),
          )
        else if (!hasLessons)
          const AubCard(
            child: AubEmptyState(message: AppStrings.noLessonsForAttendance),
          )
        else
          for (final day in days)
            if (day.lessons.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AubSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        italianWeekdayDate(day.date),
                        style: AubText.headlineMd,
                      ),
                    ),
                    if (isSameDate(day.date, now))
                      Text(
                        AppStrings.today.toUpperCase(),
                        style: AubText.labelCaps,
                      ),
                  ],
                ),
              ),
              for (final lesson in day.lessons)
                Padding(
                  padding: const EdgeInsets.only(bottom: AubSpacing.sm),
                  child: TeacherLessonCard(
                    lesson: lesson,
                    day: day,
                    now: now,
                    onOpenAttendance: onOpenAttendance == null
                        ? null
                        : () => onOpenAttendance!(lesson),
                  ),
                ),
              const SizedBox(height: AubSpacing.sm),
            ],
      ],
    );
  }
}
