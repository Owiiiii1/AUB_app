import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

class ScheduleWeekHeader extends StatelessWidget {
  const ScheduleWeekHeader({
    super.key,
    required this.startsOn,
    required this.endsOn,
    required this.onPrevious,
    required this.onNext,
    required this.onToday,
  });

  final DateTime startsOn;
  final DateTime endsOn;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onToday;

  @override
  Widget build(BuildContext context) {
    final startDay = DateFormat('d', 'it').format(startsOn);
    final endLabel = DateFormat('d MMMM y', 'it').format(endsOn);

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(Icons.chevron_left),
            ),
            Expanded(
              child: Text(
                '$startDay–$endLabel',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        TextButton(
          onPressed: onToday,
          child: const Text(AppStrings.thisWeek),
        ),
      ],
    );
  }
}

class ScheduleDaySection extends StatelessWidget {
  const ScheduleDaySection({
    super.key,
    required this.day,
    this.onLessonTap,
  });

  final ScheduleDay day;
  final ValueChanged<ScheduleLesson>? onLessonTap;

  @override
  Widget build(BuildContext context) {
    final today = const AcademyClock().now();
    final isToday = isSameDate(day.date, today);
    final title = DateFormat("EEEE d MMMM", 'it').format(day.date);
    final capitalized =
        title.isEmpty ? title : '${title[0].toUpperCase()}${title.substring(1)}';

    return Card(
      color: isToday
          ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.08)
          : null,
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalized,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            if (day.lessons.isEmpty)
              Text(
                AppStrings.noLesson,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
              )
            else
              ...day.lessons.map(
                (lesson) => ScheduleLessonTile(
                  lesson: lesson,
                  onTap: onLessonTap == null ? null : () => onLessonTap!(lesson),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class ScheduleLessonTile extends StatelessWidget {
  const ScheduleLessonTile({super.key, required this.lesson, this.onTap});

  final ScheduleLesson lesson;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cancelled = lesson.status == ScheduleLessonStatus.cancelled;
    final moved = lesson.status == ScheduleLessonStatus.moved;
    final className = lesson.academyClass?.name;
    final building = lesson.location?.building?.name;
    final room = lesson.location?.room?.name;
    final teacher = lesson.teacher?.displayName;
    final locationLine = [
      if (building != null && building.isNotEmpty) building,
      if (room != null && room.isNotEmpty) room,
    ].join(' · ');
    final showClass = className != null && className.isNotEmpty;

    final tile = Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${lesson.startsAt} – ${lesson.endsAt}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: cancelled ? TextDecoration.lineThrough : null,
                    color: cancelled ? Theme.of(context).hintColor : null,
                  ),
                ),
              ),
              if (cancelled)
                const _StatusBadge(label: AppStrings.cancelled, muted: true),
              if (moved) const _StatusBadge(label: AppStrings.moved),
              if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).hintColor,
                ),
            ],
          ),
          Text(
            lesson.title,
            style: TextStyle(
              decoration: cancelled ? TextDecoration.lineThrough : null,
              color: cancelled ? Theme.of(context).hintColor : null,
            ),
          ),
          if (showClass)
            Text(className, style: Theme.of(context).textTheme.bodySmall),
          if (showClass && locationLine.isNotEmpty)
            Text(locationLine, style: Theme.of(context).textTheme.bodySmall)
          else if (!showClass && room != null && room.isNotEmpty)
            Text(room, style: Theme.of(context).textTheme.bodySmall),
          if (!showClass && teacher != null && teacher.isNotEmpty)
            Text(teacher, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return InkWell(
      onTap: onTap,
      child: tile,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, this.muted = false});

  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: muted
            ? Theme.of(context).disabledColor.withValues(alpha: 0.15)
            : Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
