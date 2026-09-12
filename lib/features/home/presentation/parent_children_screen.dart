import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/italian_dates.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/home/state/parent_home_controller.dart';
import 'package:aub/features/home/state/parent_home_state.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';
import 'package:aub/shared/widgets/child_switcher.dart';

class ParentChildrenScreen extends StatelessWidget {
  const ParentChildrenScreen({
    super.key,
    required this.profile,
    required this.controller,
    required this.selectedChildId,
    required this.onSelectChild,
    this.onOpenSchedule,
    this.onOpenAttendance,
  });

  final ParentProfile profile;
  final ParentHomeController controller;
  final int? selectedChildId;
  final ValueChanged<ParentChild> onSelectChild;
  final ValueChanged<ParentChild>? onOpenSchedule;
  final ValueChanged<ParentChild>? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return switch (state.status) {
          ParentHomeStatus.loading => const AubLoading(),
          ParentHomeStatus.error => AubErrorState(
              message: state.errorMessage ?? AppStrings.serverError,
              onRetry: controller.retry,
            ),
          ParentHomeStatus.loaded => _ChildrenLoaded(
              profile: profile,
              state: state,
              selectedChildId: selectedChildId,
              onSelectChild: onSelectChild,
              onOpenSchedule: onOpenSchedule,
              onOpenAttendance: onOpenAttendance,
            ),
        };
      },
    );
  }
}

class _ChildrenLoaded extends StatelessWidget {
  const _ChildrenLoaded({
    required this.profile,
    required this.state,
    required this.selectedChildId,
    required this.onSelectChild,
    this.onOpenSchedule,
    this.onOpenAttendance,
  });

  final ParentProfile profile;
  final ParentHomeState state;
  final int? selectedChildId;
  final ValueChanged<ParentChild> onSelectChild;
  final ValueChanged<ParentChild>? onOpenSchedule;
  final ValueChanged<ParentChild>? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    if (profile.children.isEmpty) {
      return const AubEmptyState(message: AppStrings.noChildren);
    }

    ParentChild selected = profile.children.first;
    for (final child in profile.children) {
      if (child.id == selectedChildId) {
        selected = child;
        break;
      }
    }
    final dashboard = state.dashboardFor(selected.id);
    final now = state.now ?? const AcademyClock().now();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        ChildSwitcher(
          children: profile.children,
          selected: selected,
          onSelect: onSelectChild,
        ),
        const SizedBox(height: AubSpacing.md),
        AubCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AubAvatar(size: 80, name: selected.displayName, photoUrl: selected.photoUrl),
              const SizedBox(width: AubSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(selected.displayName, style: AubText.headlineLg),
                    const SizedBox(height: 4),
                    Text(
                      selected.academyClass?.name ?? AppStrings.noClass,
                      style: AubText.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AubSpacing.md),
        if (dashboard?.errorMessage != null)
          AubCard(child: Text(dashboard!.errorMessage!, style: AubText.bodySm))
        else ...[
          _NextLessonHero(dashboard: dashboard, now: now),
          const SizedBox(height: AubSpacing.md),
          _AttendanceBlock(dashboard: dashboard),
          const SizedBox(height: AubSpacing.md),
          _TodayBlock(dashboard: dashboard, now: now),
          const SizedBox(height: AubSpacing.md),
          _RecentRecords(dashboard: dashboard),
        ],
        const SizedBox(height: AubSpacing.md),
        FilledButton(
          onPressed: onOpenSchedule == null
              ? null
              : () => onOpenSchedule!(selected),
          child: Text(AppStrings.seeFullSchedule),
        ),
        const SizedBox(height: AubSpacing.xs),
        OutlinedButton(
          onPressed: onOpenAttendance == null
              ? null
              : () => onOpenAttendance!(selected),
          child: const Text(AppStrings.seeFullAttendance),
        ),
      ],
    );
  }
}

class _NextLessonHero extends StatelessWidget {
  const _NextLessonHero({required this.dashboard, required this.now});

  final ChildDashboard? dashboard;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final upcoming = dashboard?.nextLesson;
    if (upcoming == null) {
      return const AubCard(
        child: AubEmptyState(message: AppStrings.noUpcomingLesson),
      );
    }

    final lesson = upcoming.lesson;
    final isToday = isSameDate(upcoming.day.date, now);
    final room = lesson.location?.room?.name;
    final teacher = lesson.teacher?.displayName;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AubSpacing.md),
      decoration: BoxDecoration(
        color: AubColors.navy,
        borderRadius: BorderRadius.circular(AubRadii.xxl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            (isToday ? AppStrings.nextLessonToday : AppStrings.nextLesson)
                .toUpperCase(),
            style: AubText.labelCaps.copyWith(color: AubColors.gold),
          ),
          const SizedBox(height: 6),
          Text(
            lesson.title,
            style: AubText.headlineMd.copyWith(color: Colors.white),
          ),
          Text(
            '${lesson.startsAt} – ${lesson.endsAt}',
            style: AubText.bodySm.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: AubSpacing.sm),
          Wrap(
            spacing: AubSpacing.sm,
            runSpacing: 8,
            children: [
              if (teacher != null && teacher.isNotEmpty)
                _NavyMeta(label: AppStrings.teacherLabel, value: teacher),
              if (room != null && room.isNotEmpty)
                _NavyMeta(label: AppStrings.spaceAndVenue, value: room),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavyMeta extends StatelessWidget {
  const _NavyMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AubRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: AubText.labelCaps.copyWith(color: Colors.white54),
          ),
          Text(
            value,
            style: AubText.labelMd.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class _AttendanceBlock extends StatelessWidget {
  const _AttendanceBlock({required this.dashboard});

  final ChildDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    final summary = dashboard?.history?.summary;
    return AubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.attendanceSummary.toUpperCase(),
            style: AubText.labelCaps.copyWith(color: AubColors.gold),
          ),
          const SizedBox(height: AubSpacing.sm),
          if (summary == null || summary.marked == 0)
            const AubEmptyState(message: AppStrings.noAttendanceThisMonth)
          else
            Row(
              children: [
                _Stat(
                  value: summary.marked,
                  label: AppStrings.totalLabel,
                  color: AubColors.textPrimary,
                  background: AubColors.surfaceSubtle,
                ),
                const SizedBox(width: AubSpacing.xs),
                _Stat(
                  value: summary.present,
                  label: AppStrings.presentPlural,
                  color: AubColors.success,
                  background: AubColors.successBg,
                ),
                const SizedBox(width: AubSpacing.xs),
                _Stat(
                  value: summary.absent,
                  label: AppStrings.absentPlural,
                  color: AubColors.alert,
                  background: AubColors.alertBg,
                ),
                const SizedBox(width: AubSpacing.xs),
                _Stat(
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

class _Stat extends StatelessWidget {
  const _Stat({
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
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AubRadii.lg),
        ),
        child: Column(
          children: [
            Text('$value', style: AubText.headlineSm.copyWith(color: color)),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: AubText.labelCaps.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayBlock extends StatelessWidget {
  const _TodayBlock({required this.dashboard, required this.now});

  final ChildDashboard? dashboard;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final today = dashboard?.todayLessons ?? const [];
    return AubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.todaySchedule, style: AubText.headlineSm),
              ),
              Text(
                italianWeekdayDate(now),
                style: AubText.labelCaps,
              ),
            ],
          ),
          const SizedBox(height: AubSpacing.sm),
          if (today.isEmpty)
            const AubEmptyState(message: AppStrings.noLessonToday)
          else
            for (final item in today)
              Padding(
                padding: const EdgeInsets.only(bottom: AubSpacing.xs),
                child: _LessonRow(lesson: item.lesson),
              ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  const _LessonRow({required this.lesson});

  final ScheduleLesson lesson;

  @override
  Widget build(BuildContext context) {
    final cancelled = lesson.status == ScheduleLessonStatus.cancelled;
    final room = lesson.location?.room?.name;
    final teacher = lesson.teacher?.displayName;
    return Row(
      children: [
        SizedBox(
          width: 52,
          child: Column(
            children: [
              Text(lesson.startsAt, style: AubText.headlineSm),
              Text(lesson.endsAt, style: AubText.labelSm),
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AubText.labelMd.copyWith(
                  decoration: cancelled ? TextDecoration.lineThrough : null,
                ),
              ),
              Text(
                [
                  if (teacher != null && teacher.isNotEmpty) teacher,
                  if (room != null && room.isNotEmpty) room,
                ].join(' · '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AubText.bodySm,
              ),
            ],
          ),
        ),
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
        ),
      ],
    );
  }
}

class _RecentRecords extends StatelessWidget {
  const _RecentRecords({required this.dashboard});

  final ChildDashboard? dashboard;

  @override
  Widget build(BuildContext context) {
    final records = dashboard?.history?.records ?? const [];
    final preview = records.take(3).toList();
    return AubCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.recentRecords, style: AubText.headlineSm),
          const SizedBox(height: AubSpacing.sm),
          if (preview.isEmpty)
            const AubEmptyState(message: AppStrings.noAttendanceThisMonth)
          else
            for (final record in preview)
              Padding(
                padding: const EdgeInsets.only(bottom: AubSpacing.xs),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 36,
                      decoration: BoxDecoration(
                        color: switch (record.status) {
                          AttendanceStatus.present => AubColors.success,
                          AttendanceStatus.absent => AubColors.alert,
                          AttendanceStatus.excused => AubColors.warning,
                        },
                        borderRadius: BorderRadius.circular(AubRadii.pill),
                      ),
                    ),
                    const SizedBox(width: AubSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dateLabel(record.date),
                            style: AubText.labelMd,
                          ),
                          Text(
                            '${record.title} · ${record.startsAt} – ${record.endsAt}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AubText.bodySm,
                          ),
                        ],
                      ),
                    ),
                    AubStatusBadge(
                      label: switch (record.status) {
                        AttendanceStatus.present => AppStrings.present,
                        AttendanceStatus.absent => AppStrings.absent,
                        AttendanceStatus.excused => AppStrings.excused,
                      },
                      tone: switch (record.status) {
                        AttendanceStatus.present => AubBadgeTone.success,
                        AttendanceStatus.absent => AubBadgeTone.alert,
                        AttendanceStatus.excused => AubBadgeTone.warning,
                      },
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }

  String _dateLabel(String raw) {
    return italianWeekdayDate(parseDateOnly(raw));
  }
}
