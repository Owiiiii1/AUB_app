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
    expect(empty.student?.academyClass, isNull);
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

  test('parses teacher week with academy class', () {
    final view = ScheduleWeekView.fromJson(teacherScheduleJson());
    expect(view.student, isNull);
    expect(view.teacher?.id, 7);
    expect(view.teacher?.displayName, 'Maria Rossi');
    expect(view.days.first.lessons.single.academyClass?.name, 'Classe A');
    expect(view.days.first.lessons.single.location?.building?.name, 'Sede centrale');
  });

  test('parses teacher two classes cancelled and moved', () {
    final view = ScheduleWeekView.fromJson(
      teacherScheduleJson(
        extraLessons: [
          {
            'id': 102,
            'starts_at': '18:00',
            'ends_at': '19:00',
            'title': 'Repertorio',
            'lesson': {'id': 5, 'name': 'Repertorio'},
            'academy_class': {'id': 4, 'name': 'Classe B'},
            'location': {
              'building': {'id': 1, 'name': 'Sede centrale'},
              'room': {'id': 5, 'name': 'Sala 1'},
            },
            'status': 'moved',
          },
        ],
      ),
    );
    expect(view.days.first.lessons, hasLength(2));
    expect(view.days.first.lessons[0].academyClass?.name, 'Classe A');
    expect(view.days.first.lessons[1].academyClass?.name, 'Classe B');
    expect(view.days.first.lessons[1].status, ScheduleLessonStatus.moved);

    final cancelled = ScheduleWeekView.fromJson(teacherScheduleJson(status: 'cancelled'));
    expect(cancelled.days.first.lessons.single.status, ScheduleLessonStatus.cancelled);
  });

  test('parses teacher empty weeks', () {
    final empty = ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: true));
    expect(empty.emptyReason, ScheduleEmptyReason.noLessons);
    expect(empty.days.every((day) => day.lessons.isEmpty), isTrue);

    final unpublished = ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: false));
    expect(unpublished.emptyReason, ScheduleEmptyReason.unpublished);
  });

  test('rejects teacher malformed payload', () {
    expect(
      () => ScheduleWeekView.fromJson({'teacher': 'bad', 'week': <String, dynamic>{}}),
      throwsFormatException,
    );
  });
}
