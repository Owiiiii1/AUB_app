import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/schedule_fixtures.dart';

void main() {
  test('parses a published week', () {
    final view = ScheduleWeekView.fromJson(publishedScheduleJson());
    expect(view.week.published, isTrue);
    expect(view.days, hasLength(7));
    expect(view.days.first.lessons.single.title, 'Danza classica');
    expect(view.days.first.lessons.single.startsAt, '16:00');
    expect(view.days.first.lessons.single.teacher?.displayName, 'Maria Rossi');
    expect(view.days.first.lessons.single.location?.room?.name, 'Sala 2');
    expect(view.emptyReason, ScheduleEmptyReason.none);
  });

  test('parses cancelled and moved lessons', () {
    final cancelled = ScheduleWeekView.fromJson(
      publishedScheduleJson(status: 'cancelled', title: 'Annullata lezione'),
    );
    expect(cancelled.days.first.lessons.single.status, ScheduleLessonStatus.cancelled);

    final moved = ScheduleWeekView.fromJson(
      publishedScheduleJson(status: 'moved', startsAt: '18:00', endsAt: '19:00'),
    );
    expect(moved.days.first.lessons.single.status, ScheduleLessonStatus.moved);
    expect(moved.days.first.lessons.single.startsAt, '18:00');
  });

  test('parses unpublished and empty class payloads', () {
    final unpublished = ScheduleWeekView.fromJson(unpublishedScheduleJson());
    expect(unpublished.week.published, isFalse);
    expect(unpublished.emptyReason, ScheduleEmptyReason.unpublished);

    final empty = ScheduleWeekView.fromJson(emptyClassScheduleJson());
    expect(empty.student.academyClass, isNull);
    expect(empty.days, isEmpty);
    expect(empty.emptyReason, ScheduleEmptyReason.noClass);
  });

  test('rejects malformed payload', () {
    expect(() => ScheduleWeekView.fromJson(const {}), throwsFormatException);
    expect(
      () => ScheduleWeekView.fromJson(publishedScheduleJson(status: 'draft')),
      throwsFormatException,
    );
  });
}
