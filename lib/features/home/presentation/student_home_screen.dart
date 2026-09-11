import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/lesson_time.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/home/state/student_home_controller.dart';
import 'package:aub/features/home/state/student_home_state.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({
    super.key,
    required this.profile,
    required this.controller,
    this.onOpenSchedule,
    this.onOpenAttendance,
    this.onOpenProfile,
  });

  final StudentProfile profile;
  final StudentHomeController controller;
  final VoidCallback? onOpenSchedule;
  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenProfile;

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  String get _greetingName {
    final first = widget.profile.firstName?.trim();
    if (first != null && first.isNotEmpty) {
      return first;
    }
    return widget.profile.displayName;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return switch (state.status) {
          StudentHomeStatus.loading => const AubLoading(),
          StudentHomeStatus.error => AubErrorState(
              message: state.errorMessage ?? AppStrings.serverError,
              onRetry: widget.controller.retry,
            ),
          StudentHomeStatus.loaded => _HomeLoaded(
              profile: widget.profile,
              greetingName: _greetingName,
              state: state,
              onOpenSchedule: widget.onOpenSchedule,
              onOpenAttendance: widget.onOpenAttendance,
              onOpenProfile: widget.onOpenProfile,
            ),
        };
      },
    );
  }
}

class _HomeLoaded extends StatelessWidget {
  const _HomeLoaded({
    required this.profile,
    required this.greetingName,
    required this.state,
    this.onOpenSchedule,
    this.onOpenAttendance,
    this.onOpenProfile,
  });

  final StudentProfile profile;
  final String greetingName;
  final StudentHomeState state;
  final VoidCallback? onOpenSchedule;
  final VoidCallback? onOpenAttendance;
  final VoidCallback? onOpenProfile;

  @override
  Widget build(BuildContext context) {
    final className = profile.academyClass?.name;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.ciao(greetingName).toUpperCase(),
                    style: AubText.headlineLg,
                  ),
                  if (className != null && className.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: AubColors.burgundy,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            [
                              className,
                              if (profile.academicYear?.name != null &&
                                  profile.academicYear!.name.isNotEmpty)
                                profile.academicYear!.name,
                            ].join(' · '),
                            style: AubText.bodySm,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            GestureDetector(
              onTap: onOpenProfile,
              child: AubAvatar(
                size: 48,
                photoUrl: profile.photoUrl,
                name: profile.displayName,
                showActiveDot: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: AubSpacing.xl),
        _NextLessonCard(state: state),
        const SizedBox(height: AubSpacing.xl),
        AubSectionTitle(
          title: AppStrings.todayLessons,
          count: state.todayLessons.isEmpty ? null : state.todayLessons.length,
          trailing: TextButton(
            onPressed: onOpenSchedule,
            child: Text(
              AppStrings.allSchedule,
              style: AubText.labelMd.copyWith(color: AubColors.burgundy),
            ),
          ),
        ),
        const SizedBox(height: AubSpacing.sm),
        if (state.todayLessons.isEmpty)
          AubCard(
            child: AubEmptyState(message: AppStrings.noLessonToday),
          )
        else
          ...state.todayLessons.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: AubSpacing.xs),
              child: _TodayLessonRow(
                lesson: item.lesson,
                isNext: state.nextLesson?.lesson.id == item.lesson.id,
              ),
            ),
          ),
        const SizedBox(height: AubSpacing.lg),
        AubSectionTitle(
          title: AppStrings.recentAttendance,
          trailing: profile.academicYear == null
              ? null
              : Text(
                  profile.academicYear!.name.toUpperCase(),
                  style: AubText.labelCaps.copyWith(color: AubColors.gold),
                ),
        ),
        const SizedBox(height: AubSpacing.xs),
        _AttendanceSummaryCard(history: state.history),
        const SizedBox(height: AubSpacing.xl),
        AubSectionTitle(title: AppStrings.fullSchedule),
        const SizedBox(height: AubSpacing.xs),
        Row(
          children: [
            Expanded(
              child: _QuickAction(
                icon: Icons.calendar_month_outlined,
                label: AppStrings.schedule,
                color: AubColors.burgundy,
                background: AubColors.burgundyLight,
                onTap: onOpenSchedule,
              ),
            ),
            const SizedBox(width: AubSpacing.sm),
            Expanded(
              child: _QuickAction(
                icon: Icons.fact_check_outlined,
                label: AppStrings.attendance,
                color: AubColors.navy,
                background: AubColors.surfaceSubtle,
                onTap: onOpenAttendance,
              ),
            ),
            const SizedBox(width: AubSpacing.sm),
            Expanded(
              child: _QuickAction(
                icon: Icons.person_outline,
                label: AppStrings.myProfile,
                color: AubColors.gold,
                background: AubColors.goldLight,
                onTap: onOpenProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard({required this.state});

  final StudentHomeState state;

  @override
  Widget build(BuildContext context) {
    final upcoming = state.nextLesson;
    if (upcoming == null) {
      return AubCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.nextLesson.toUpperCase(),
              style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
            ),
            const SizedBox(height: AubSpacing.xs),
            const AubEmptyState(message: AppStrings.noUpcomingLesson),
          ],
        ),
      );
    }

    final lesson = upcoming.lesson;
    final now = state.now ?? DateTime.now();
    final start = combineDateAndClock(upcoming.day.date, lesson.startsAt);
    final minutes = start?.difference(now).inMinutes;
    final timing = start != null && isSameDate(upcoming.day.date, now)
        ? (minutes != null && minutes > 0
            ? AppStrings.inMinutes(minutes)
            : AppStrings.today)
        : AppStrings.nextLesson;
    final duration = durationMinutes(lesson.startsAt, lesson.endsAt);
    final room = lesson.location?.room?.name;
    final building = lesson.location?.building?.name;
    final venue = [
      if (room != null && room.isNotEmpty) room,
      if (building != null && building.isNotEmpty) building,
    ].join(' · ');

    return AubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AubColors.burgundyLight,
                  borderRadius: BorderRadius.circular(AubRadii.pill),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.timer, size: 14, color: AubColors.burgundy),
                    const SizedBox(width: 6),
                    Text(
                      timing.toUpperCase(),
                      style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (lesson.academyClass?.name != null)
                Text(
                  lesson.academyClass!.name.toUpperCase(),
                  style: AubText.labelCaps,
                ),
            ],
          ),
          const SizedBox(height: AubSpacing.sm),
          Text(
            AppStrings.nextLesson.toUpperCase(),
            style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
          ),
          Text(lesson.title, style: AubText.headlineMd),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(lesson.startsAt, style: AubText.headlineXl),
              const SizedBox(width: 8),
              Text(
                '— ${lesson.endsAt}',
                style: AubText.bodyMd.copyWith(color: AubColors.textMuted),
              ),
              if (duration != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AubColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(AubRadii.pill),
                  ),
                  child: Text(
                    AppStrings.durationMin(duration),
                    style: AubText.labelSm,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AubSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AubSpacing.sm),
            decoration: BoxDecoration(
              color: AubColors.surfaceIvory.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(AubRadii.lg),
            ),
            child: Column(
              children: [
                if (lesson.teacher?.displayName != null)
                  _MetaRow(
                    icon: Icons.person_outline,
                    label: AppStrings.teacherLabel,
                    value: lesson.teacher!.displayName,
                  ),
                if (venue.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _MetaRow(
                    icon: Icons.meeting_room_outlined,
                    label: AppStrings.spaceAndVenue,
                    value: venue,
                    iconColor: AubColors.burgundy,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: AubColors.surfaceCard,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: iconColor ?? AubColors.textMuted),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label.toUpperCase(), style: AubText.labelCaps.copyWith(color: AubColors.textMuted)),
              Text(value, style: AubText.bodySm.copyWith(color: AubColors.textPrimary, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }
}

class _TodayLessonRow extends StatelessWidget {
  const _TodayLessonRow({required this.lesson, required this.isNext});

  final ScheduleLesson lesson;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final cancelled = lesson.status == ScheduleLessonStatus.cancelled;
    final room = lesson.location?.room?.name;
    final teacher = lesson.teacher?.displayName;
    final subtitle = [
      if (room != null && room.isNotEmpty) room,
      if (teacher != null && teacher.isNotEmpty) teacher,
    ].join(' · ');

    return AubCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 56,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
            decoration: BoxDecoration(
              color: isNext
                  ? AubColors.burgundyLight.withValues(alpha: 0.7)
                  : AubColors.surfaceContainer,
              borderRadius: BorderRadius.circular(AubRadii.lg),
            ),
            child: Column(
              children: [
                Text(
                  lesson.startsAt,
                  style: AubText.headlineSm.copyWith(
                    color: isNext ? AubColors.burgundy : AubColors.textPrimary,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lesson.endsAt,
                  style: AubText.labelSm.copyWith(color: AubColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AubSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AubText.bodyMd.copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                    color: cancelled ? AubColors.textMuted : AubColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AubText.bodySm,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AubStatusBadge(
            label: cancelled
                ? AppStrings.cancelled
                : lesson.status == ScheduleLessonStatus.moved
                    ? AppStrings.moved
                    : AppStrings.confirmed,
            tone: cancelled
                ? AubBadgeTone.alert
                : lesson.status == ScheduleLessonStatus.moved
                    ? AubBadgeTone.warning
                    : AubBadgeTone.success,
            icon: cancelled
                ? Icons.cancel
                : lesson.status == ScheduleLessonStatus.moved
                    ? Icons.update
                    : Icons.check_circle,
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummaryCard extends StatelessWidget {
  const _AttendanceSummaryCard({required this.history});

  final AttendanceHistory? history;

  @override
  Widget build(BuildContext context) {
    final summary = history?.summary;
    final empty = summary == null || summary.marked == 0;
    if (empty) {
      return const AubCard(
        child: AubEmptyState(message: AppStrings.noAttendanceThisMonth),
      );
    }

    return AubCard(
      child: Column(
        children: [
          Row(
            children: [
              Text('${summary.marked}', style: AubText.headlineLg),
              const SizedBox(width: 6),
              Text(
                AppStrings.sessionsLabel,
                style: AubText.bodySm,
              ),
            ],
          ),
          const SizedBox(height: AubSpacing.md),
          Row(
            children: [
              _MiniStat(
                value: summary.present,
                label: AppStrings.presentPlural,
                color: AubColors.success,
                background: AubColors.successBg,
              ),
              const SizedBox(width: AubSpacing.xs),
              _MiniStat(
                value: summary.absent,
                label: AppStrings.absentPlural,
                color: AubColors.alert,
                background: AubColors.alertBg,
              ),
              const SizedBox(width: AubSpacing.xs),
              _MiniStat(
                value: summary.excused,
                label: AppStrings.excusedPlural,
                color: AubColors.warning,
                background: AubColors.warningBg,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.color,
    required this.background,
  });

  final int value;
  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(AubRadii.xl),
        ),
        child: Column(
          children: [
            Text('$value', style: AubText.headlineSm.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: AubText.labelCaps.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.background,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color background;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AubCard(
      padding: const EdgeInsets.all(AubSpacing.sm),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: AubSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AubText.labelSm.copyWith(color: AubColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
