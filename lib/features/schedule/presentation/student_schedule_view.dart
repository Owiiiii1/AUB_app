import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/italian_dates.dart';
import 'package:aub/core/time/lesson_time.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';

class StudentScheduleView extends StatelessWidget {
  const StudentScheduleView({
    super.key,
    required this.view,
    required this.controller,
    this.banner,
    this.onLessonTap,
  });

  final ScheduleWeekView view;
  final ScheduleController controller;
  final String? banner;
  final ValueChanged<ScheduleLesson>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _WeekToolbar(view: view, controller: controller),
        Expanded(
          child: ListView(
            cacheExtent: 4000,
            padding: const EdgeInsets.fromLTRB(
              AubSpacing.margin,
              AubSpacing.sm,
              AubSpacing.margin,
              AubSpacing.xl,
            ),
            children: [
              if (banner != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: AubSpacing.sm),
                  child: Text(
                    banner!,
                    textAlign: TextAlign.center,
                    style: AubText.bodySm,
                  ),
                ),
              ...view.days.map(
                (day) => _StudentDaySection(
                  day: day,
                  onLessonTap: onLessonTap,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeekToolbar extends StatelessWidget {
  const _WeekToolbar({required this.view, required this.controller});

  final ScheduleWeekView view;
  final ScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final now = const AcademyClock().now();
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.sm,
        AubSpacing.margin,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppStrings.weeklySchedule.toUpperCase(), style: AubText.headlineLg),
          const SizedBox(height: AubSpacing.sm),
          AubCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Row(
                  children: [
                    _RoundIcon(
                      icon: Icons.chevron_left,
                      onTap: controller.loadPrevious,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        italianWeekRange(view.week.startsOn, view.week.endsOn),
                        style: AubText.headlineSm,
                      ),
                    ),
                    _RoundIcon(
                      icon: Icons.chevron_right,
                      onTap: controller.loadNext,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton(
                    onPressed: controller.loadToday,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      backgroundColor: AubColors.navy,
                    ),
                    child: const Text(AppStrings.thisWeek),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    for (final day in view.days)
                      Expanded(
                        child: _DayChip(
                          day: day,
                          selected: isSameDate(day.date, now),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  const _RoundIcon({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AubRadii.lg),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AubColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AubRadii.lg),
        ),
        child: Icon(icon, size: 20, color: AubColors.navy),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day, required this.selected});

  final ScheduleDay day;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: selected ? AubColors.navy : AubColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(AubRadii.lg),
      ),
      child: Column(
        children: [
          Text(
            italianWeekdayShort(day.date),
            style: AubText.labelCaps.copyWith(
              color: selected ? AubColors.gold : AubColors.textMuted,
              fontSize: 10,
            ),
          ),
          Text(
            day.date.day.toString().padLeft(2, '0'),
            style: AubText.headlineSm.copyWith(
              color: selected ? AubColors.onNavy : AubColors.textPrimary,
              height: 1.1,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: day.lessons.isEmpty
                  ? Colors.transparent
                  : selected
                      ? AubColors.gold
                      : AubColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _StudentDaySection extends StatelessWidget {
  const _StudentDaySection({required this.day, this.onLessonTap});

  final ScheduleDay day;
  final ValueChanged<ScheduleLesson>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    final today = isSameDate(day.date, const AcademyClock().now());
    return Padding(
      padding: const EdgeInsets.only(bottom: AubSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      italianWeekdayDate(day.date),
                      style: AubText.headlineMd,
                    ),
                    if (today)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AubColors.navy,
                          borderRadius: BorderRadius.circular(AubRadii.pill),
                        ),
                        child: Text(
                          AppStrings.today.toUpperCase(),
                          style: AubText.labelCaps.copyWith(color: AubColors.onNavy),
                        ),
                      ),
                  ],
                ),
              ),
              Text(
                day.lessons.isEmpty
                    ? AppStrings.restDay
                    : AppStrings.lessonsCount(day.lessons.length),
                style: AubText.labelSm,
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (day.lessons.isEmpty)
            AubCard(
              child: Text(
                AppStrings.emptyDaySchedule,
                style: AubText.bodySm,
              ),
            )
          else
            ...day.lessons.map(
              (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: AubSpacing.sm),
                child: _StudentLessonCard(
                  lesson: lesson,
                  onTap: onLessonTap == null ? null : () => onLessonTap!(lesson),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class StudentLessonCard extends StatelessWidget {
  const StudentLessonCard({super.key, required this.lesson, this.onTap});

  final ScheduleLesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return _StudentLessonCard(lesson: lesson, onTap: onTap);
  }
}

class _StudentLessonCard extends StatelessWidget {
  const _StudentLessonCard({required this.lesson, this.onTap});

  final ScheduleLesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cancelled = lesson.status == ScheduleLessonStatus.cancelled;
    final moved = lesson.status == ScheduleLessonStatus.moved;
    final strip = cancelled
        ? AubColors.alert
        : moved
            ? AubColors.warning
            : AubColors.gold;
    final badge = cancelled
        ? const AubStatusBadge(
            label: AppStrings.cancelled,
            tone: AubBadgeTone.alert,
            icon: Icons.cancel,
          )
        : moved
            ? const AubStatusBadge(
                label: AppStrings.moved,
                tone: AubBadgeTone.warning,
                icon: Icons.update,
              )
            : const AubStatusBadge(
                label: AppStrings.confirmed,
                tone: AubBadgeTone.success,
                icon: Icons.check_circle,
              );
    final duration = durationMinutes(lesson.startsAt, lesson.endsAt);
    final room = lesson.location?.room?.name;
    final building = lesson.location?.building?.name;
    final venue = [
      if (room != null && room.isNotEmpty) room,
      if (building != null && building.isNotEmpty) building,
    ].join(' · ');
    final teacher = lesson.teacher?.displayName;

    return AubCard(
      stripColor: strip,
      color: cancelled ? AubColors.surfaceContainerLow : AubColors.surfaceCard,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${lesson.startsAt} – ${lesson.endsAt}',
                      style: AubText.labelMd.copyWith(
                        decoration: cancelled ? TextDecoration.lineThrough : null,
                        color: cancelled ? AubColors.textMuted : AubColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title.toUpperCase(),
                      style: AubText.headlineMd.copyWith(
                        decoration: cancelled ? TextDecoration.lineThrough : null,
                        color: cancelled ? AubColors.textMuted : AubColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              badge,
            ],
          ),
          const SizedBox(height: AubSpacing.sm),
          if (teacher != null && teacher.isNotEmpty)
            Text(teacher, style: AubText.bodySm.copyWith(color: AubColors.textPrimary)),
          if (venue.isNotEmpty || duration != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  if (venue.isNotEmpty)
                    Expanded(
                      child: Text(venue, style: AubText.bodySm),
                    ),
                  if (duration != null)
                    Text(
                      AppStrings.durationMin(duration).toUpperCase(),
                      style: AubText.labelCaps.copyWith(color: AubColors.textMuted),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
