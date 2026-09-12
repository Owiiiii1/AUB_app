import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/lesson_time.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';

class TeacherLessonCard extends StatelessWidget {
  const TeacherLessonCard({
    super.key,
    required this.lesson,
    this.day,
    this.now,
    this.onOpenAttendance,
    this.highlight = false,
  });

  final ScheduleLesson lesson;
  final ScheduleDay? day;
  final DateTime? now;
  final VoidCallback? onOpenAttendance;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cancelled = lesson.status == ScheduleLessonStatus.cancelled;
    final moved = lesson.status == ScheduleLessonStatus.moved;
    final ongoing = day != null && now != null
        ? isLessonOngoing(day!, lesson, now!)
        : false;
    final strip = cancelled
        ? AubColors.alert
        : highlight || ongoing
            ? AubColors.gold
            : moved
                ? AubColors.warning
                : AubColors.success;
    final className = lesson.academyClass?.name;
    final venue = _venue(lesson);
    final duration = durationMinutes(lesson.startsAt, lesson.endsAt);

    return AubCard(
      stripColor: strip,
      color: cancelled ? AubColors.surfaceContainerLow : AubColors.surfaceCard,
      onTap: onOpenAttendance,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          '${lesson.startsAt} – ${lesson.endsAt}',
                          style: AubText.labelMd.copyWith(
                            decoration: cancelled
                                ? TextDecoration.lineThrough
                                : null,
                            color: cancelled
                                ? AubColors.textMuted
                                : AubColors.textPrimary,
                          ),
                        ),
                        if (duration != null)
                          Text(
                            AppStrings.durationMin(duration),
                            style: AubText.labelCaps.copyWith(
                              color: AubColors.textMuted,
                            ),
                          ),
                        if (ongoing)
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
                              AppStrings.nowLabel.toUpperCase(),
                              style: AubText.labelCaps.copyWith(
                                color: AubColors.onNavy,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lesson.title,
                      style: AubText.headlineMd.copyWith(
                        decoration: cancelled
                            ? TextDecoration.lineThrough
                            : null,
                        color: cancelled
                            ? AubColors.textMuted
                            : AubColors.textPrimary,
                      ),
                    ),
                    if (className != null && className.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(className, style: AubText.headlineSm),
                    ],
                  ],
                ),
              ),
              _statusBadge(cancelled: cancelled, moved: moved),
            ],
          ),
          if (venue.isNotEmpty) ...[
            const SizedBox(height: AubSpacing.sm),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: AubColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(venue, style: AubText.bodySm),
                ),
              ],
            ),
          ],
          if (onOpenAttendance != null && !cancelled) ...[
            const SizedBox(height: AubSpacing.md),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onOpenAttendance,
                icon: const Icon(Icons.how_to_reg, size: 18),
                label: const Text(AppStrings.openAttendance),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge({required bool cancelled, required bool moved}) {
    if (cancelled) {
      return const AubStatusBadge(
        label: AppStrings.cancelled,
        tone: AubBadgeTone.alert,
        icon: Icons.cancel,
      );
    }
    if (moved) {
      return const AubStatusBadge(
        label: AppStrings.moved,
        tone: AubBadgeTone.warning,
        icon: Icons.update,
      );
    }
    return const AubStatusBadge(
      label: AppStrings.confirmed,
      tone: AubBadgeTone.success,
      icon: Icons.check_circle,
    );
  }
}

String _venue(ScheduleLesson lesson) {
  final room = lesson.location?.room?.name;
  final building = lesson.location?.building?.name;
  return [
    if (room != null && room.isNotEmpty) room,
    if (building != null && building.isNotEmpty) building,
  ].join(' · ');
}
