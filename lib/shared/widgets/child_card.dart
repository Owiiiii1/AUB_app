import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/home/state/parent_home_state.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';

class ChildCard extends StatelessWidget {
  const ChildCard({
    super.key,
    required this.dashboard,
    this.now,
    this.onTap,
    this.onOpenSchedule,
    this.onOpenAttendance,
  });

  final ChildDashboard dashboard;
  final DateTime? now;
  final VoidCallback? onTap;
  final VoidCallback? onOpenSchedule;
  final VoidCallback? onOpenAttendance;

  @override
  Widget build(BuildContext context) {
    final child = dashboard.child;
    final className = child.academyClass?.name;
    final restToday = dashboard.todayLessons.isEmpty;
    final strip = restToday ? AubColors.navy : AubColors.success;

    return AubCard(
      key: Key('parent-child-card-${child.id}'),
      stripColor: strip,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AubAvatar(size: 56, name: child.displayName, photoUrl: child.photoUrl),
              const SizedBox(width: AubSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AubText.headlineMd,
                    ),
                    if (className != null && className.isNotEmpty)
                      Text(
                        className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AubText.bodySm,
                      )
                    else
                      Text(AppStrings.noClass, style: AubText.bodySm),
                    const SizedBox(height: 6),
                    AubStatusBadge(
                      label: restToday ? AppStrings.todayAtRest : AppStrings.today,
                      tone: restToday ? AubBadgeTone.muted : AubBadgeTone.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AubSpacing.md),
          if (dashboard.errorMessage != null)
            Text(dashboard.errorMessage!, style: AubText.bodySm)
          else ...[
            _NextLessonPreview(dashboard: dashboard, now: now),
            const SizedBox(height: AubSpacing.sm),
            _AttendancePreview(dashboard: dashboard),
          ],
          const SizedBox(height: AubSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  key: Key('parent-child-orario-${child.id}'),
                  icon: Icons.schedule,
                  label: AppStrings.scheduleOfShort(child.givenName),
                  onTap: onOpenSchedule,
                ),
              ),
              const SizedBox(width: AubSpacing.xs),
              Expanded(
                child: _ActionButton(
                  key: Key('parent-child-presenze-${child.id}'),
                  icon: Icons.fact_check_outlined,
                  label: AppStrings.attendance,
                  onTap: onOpenAttendance,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextLessonPreview extends StatelessWidget {
  const _NextLessonPreview({required this.dashboard, this.now});

  final ChildDashboard dashboard;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final upcoming = dashboard.nextLesson;
    if (upcoming == null) {
      return const AubEmptyState(message: AppStrings.noUpcomingLesson);
    }

    final lesson = upcoming.lesson;
    final academyNow = now ?? const AcademyClock().now();
    final isToday = isSameDate(upcoming.day.date, academyNow);
    final start = academyLessonStart(upcoming.day.date, lesson.startsAt);
    final minutes = start?.difference(toAcademyTime(academyNow)).inMinutes;
    final room = lesson.location?.room?.name;
    final teacher = lesson.teacher?.displayName;
    final meta = [
      if (room != null && room.isNotEmpty) room,
      if (teacher != null && teacher.isNotEmpty) teacher,
    ].join(' · ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AubSpacing.sm),
      decoration: BoxDecoration(
        color: AubColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AubRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (isToday ? AppStrings.nextLessonToday : AppStrings.nextLesson)
                      .toUpperCase(),
                  style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
                ),
              ),
              Text(
                '${lesson.startsAt} – ${lesson.endsAt}',
                style: AubText.labelSm.copyWith(color: AubColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(lesson.title, style: AubText.headlineSm),
          if (meta.isNotEmpty)
            Text(
              meta,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AubText.bodySm,
            ),
          if (isToday && minutes != null && minutes > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                AppStrings.inMinutes(minutes),
                style: AubText.labelSm.copyWith(color: AubColors.burgundy),
              ),
            ),
        ],
      ),
    );
  }
}

class _AttendancePreview extends StatelessWidget {
  const _AttendancePreview({required this.dashboard});

  final ChildDashboard dashboard;

  @override
  Widget build(BuildContext context) {
    final summary = dashboard.history?.summary;
    if (summary == null || summary.marked == 0) {
      return Text(
        AppStrings.noAttendanceThisMonth,
        style: AubText.bodySm,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.attendanceSummary.toUpperCase(),
          style: AubText.labelCaps.copyWith(color: AubColors.textMuted),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: AubSpacing.md,
          runSpacing: 4,
          children: [
            _CountDot(
              color: AubColors.success,
              label: '${summary.present} ${AppStrings.presentPlural}',
            ),
            _CountDot(
              color: AubColors.alert,
              label: '${summary.absent} ${AppStrings.absentPlural}',
            ),
            _CountDot(
              color: AubColors.warning,
              label: '${summary.excused} ${AppStrings.excusedPlural}',
            ),
          ],
        ),
      ],
    );
  }
}

class _CountDot extends StatelessWidget {
  const _CountDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: AubText.labelSm),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AubColors.surfaceSubtle,
      borderRadius: BorderRadius.circular(AubRadii.lg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AubRadii.lg),
        child: SizedBox(
          height: 44,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: AubColors.burgundy),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AubText.labelMd,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
