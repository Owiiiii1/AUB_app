import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
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
      final start = academyLessonStart(day.date, lesson.startsAt);
      final academyNow = toAcademyTime(now);
      if (start == null || !start.isAfter(academyNow)) {
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
  final academyNow = toAcademyTime(now);
  final today = DateTime(academyNow.year, academyNow.month, academyNow.day);
  for (final day in view.days) {
    if (isSameDate(day.date, today)) {
      return [
        for (final lesson in day.lessons) (day: day, lesson: lesson),
      ];
    }
  }
  return const [];
}

List<UpcomingLesson> findUpcomingLessons(ScheduleWeekView? view, DateTime now) {
  if (view == null || view.emptyReason != ScheduleEmptyReason.none) {
    return const [];
  }

  final academyNow = toAcademyTime(now);
  final items = <({UpcomingLesson upcoming, DateTime start})>[];
  for (final day in view.days) {
    for (final lesson in day.lessons) {
      if (lesson.status == ScheduleLessonStatus.cancelled) {
        continue;
      }
      if (lesson.status != ScheduleLessonStatus.published &&
          lesson.status != ScheduleLessonStatus.moved) {
        continue;
      }
      final start = academyLessonStart(day.date, lesson.startsAt);
      if (start == null || !start.isAfter(academyNow)) {
        continue;
      }
      items.add((
        upcoming: UpcomingLesson(day: day, lesson: lesson),
        start: start,
      ));
    }
  }
  items.sort((a, b) => a.start.compareTo(b.start));
  return [for (final item in items) item.upcoming];
}

bool isLessonOngoing(ScheduleDay day, ScheduleLesson lesson, DateTime now) {
  if (lesson.status == ScheduleLessonStatus.cancelled) {
    return false;
  }
  final start = academyLessonStart(day.date, lesson.startsAt);
  final end = academyLessonStart(day.date, lesson.endsAt);
  if (start == null || end == null) {
    return false;
  }
  final academyNow = toAcademyTime(now);
  return !academyNow.isBefore(start) && academyNow.isBefore(end);
}

List<({ScheduleDay day, ScheduleLesson lesson})> weekLessons(
  ScheduleWeekView? view,
) {
  if (view == null || view.emptyReason == ScheduleEmptyReason.unpublished) {
    return const [];
  }
  return [
    for (final day in view.days)
      for (final lesson in day.lessons) (day: day, lesson: lesson),
  ];
}
