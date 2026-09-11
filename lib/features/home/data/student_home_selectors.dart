import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/lesson_time.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';

class UpcomingLesson {
  const UpcomingLesson({required this.day, required this.lesson});

  final ScheduleDay day;
  final ScheduleLesson lesson;
}

UpcomingLesson? findNextLesson(ScheduleWeekView? view, DateTime now) {
  if (view == null || view.emptyReason != ScheduleEmptyReason.none) {
    return null;
  }

  UpcomingLesson? best;
  DateTime? bestStart;

  for (final day in view.days) {
    for (final lesson in day.lessons) {
      if (lesson.status == ScheduleLessonStatus.cancelled) {
        continue;
      }
      if (lesson.status != ScheduleLessonStatus.published &&
          lesson.status != ScheduleLessonStatus.moved) {
        continue;
      }
      final start = combineDateAndClock(day.date, lesson.startsAt);
      if (start == null || !start.isAfter(now)) {
        continue;
      }
      if (bestStart == null || start.isBefore(bestStart)) {
        best = UpcomingLesson(day: day, lesson: lesson);
        bestStart = start;
      }
    }
  }
  return best;
}

List<({ScheduleDay day, ScheduleLesson lesson})> todaysLessons(
  ScheduleWeekView? view,
  DateTime now,
) {
  if (view == null || view.emptyReason == ScheduleEmptyReason.unpublished) {
    return const [];
  }
  final today = DateTime(now.year, now.month, now.day);
  for (final day in view.days) {
    if (isSameDate(day.date, today)) {
      return [
        for (final lesson in day.lessons) (day: day, lesson: lesson),
      ];
    }
  }
  return const [];
}
