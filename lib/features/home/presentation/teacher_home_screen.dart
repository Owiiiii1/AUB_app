import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/home/presentation/widgets/teacher_lesson_card.dart';
import 'package:aub/features/home/state/teacher_home_controller.dart';
import 'package:aub/features/home/state/teacher_home_state.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';

class TeacherHomeScreen extends StatefulWidget {
  const TeacherHomeScreen({
    super.key,
    required this.profile,
    required this.controller,
    this.onOpenAttendance,
    this.onOpenSchedule,
  });

  final TeacherProfile profile;
  final TeacherHomeController controller;
  final ValueChanged<ScheduleLesson>? onOpenAttendance;
  final VoidCallback? onOpenSchedule;

  @override
  State<TeacherHomeScreen> createState() => _TeacherHomeScreenState();
}

class _TeacherHomeScreenState extends State<TeacherHomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return switch (state.status) {
          TeacherHomeStatus.loading => const AubLoading(),
          TeacherHomeStatus.error => AubErrorState(
              message: state.errorMessage ?? AppStrings.serverError,
              onRetry: widget.controller.retry,
            ),
          TeacherHomeStatus.loaded => _TeacherHomeLoaded(
              profile: widget.profile,
              state: state,
              onOpenAttendance: widget.onOpenAttendance,
              onOpenSchedule: widget.onOpenSchedule,
            ),
        };
      },
    );
  }
}

class _TeacherHomeLoaded extends StatelessWidget {
  const _TeacherHomeLoaded({
    required this.profile,
    required this.state,
    this.onOpenAttendance,
    this.onOpenSchedule,
  });

  final TeacherProfile profile;
  final TeacherHomeState state;
  final ValueChanged<ScheduleLesson>? onOpenAttendance;
  final VoidCallback? onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    final now = state.now ?? const AcademyClock().now();
    final unpublished =
        state.week?.emptyReason == ScheduleEmptyReason.unpublished;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        Text(
          AppStrings.parentGreeting(profile.givenName, now),
          style: AubText.headlineLg,
        ),
        const SizedBox(height: 4),
        Text(AppStrings.teacherRole, style: AubText.bodySm),
        const SizedBox(height: AubSpacing.xl),
        _NextLessonCard(
          state: state,
          unpublished: unpublished,
          onOpenAttendance: onOpenAttendance,
        ),
        const SizedBox(height: AubSpacing.xl),
        AubSectionTitle(
          title: AppStrings.lessonsOfToday,
          count: state.todayLessons.isEmpty ? null : state.todayLessons.length,
          trailing: onOpenSchedule == null
              ? null
              : TextButton(
                  onPressed: onOpenSchedule,
                  child: Text(
                    AppStrings.allSchedule,
                    style: AubText.labelMd.copyWith(color: AubColors.burgundy),
                  ),
                ),
        ),
        const SizedBox(height: AubSpacing.sm),
        if (unpublished)
          const AubCard(
            child: AubEmptyState(message: AppStrings.unpublishedWeek),
          )
        else if (state.todayLessons.isEmpty)
          const AubCard(
            child: AubEmptyState(message: AppStrings.noLessonToday),
          )
        else
          ...state.todayLessons.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AubSpacing.sm),
              child: TeacherLessonCard(
                lesson: item.lesson,
                day: item.day,
                now: now,
                highlight: state.nextLesson?.lesson.id == item.lesson.id ||
                    isSameDate(item.day.date, now),
                onOpenAttendance: onOpenAttendance == null
                    ? null
                    : () => onOpenAttendance!(item.lesson),
              ),
            ),
          ),
      ],
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({
    required this.state,
    required this.unpublished,
    this.onOpenAttendance,
  });

  final TeacherHomeState state;
  final bool unpublished;
  final ValueChanged<ScheduleLesson>? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final upcoming = state.nextLesson;
    if (unpublished || upcoming == null) {
      return AubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.nextLesson.toUpperCase(),
              style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
            ),
            const SizedBox(height: AubSpacing.xs),
            AubEmptyState(
              message: unpublished
                  ? AppStrings.unpublishedWeek
                  : AppStrings.noUpcomingLesson,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.nextLesson.toUpperCase(),
          style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
        ),
        const SizedBox(height: AubSpacing.sm),
        TeacherLessonCard(
          lesson: upcoming.lesson,
          day: upcoming.day,
          now: state.now,
          highlight: true,
          onOpenAttendance: onOpenAttendance == null
              ? null
              : () => onOpenAttendance!(upcoming.lesson),
        ),
      ],
    );
  }
}
