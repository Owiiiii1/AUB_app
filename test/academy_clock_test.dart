import 'package:aub/core/time/clock.dart';
import 'package:aub/features/home/data/student_home_selectors.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;

import 'helpers/schedule_fixtures.dart';

void main() {
  setUpAll(ensureAcademyTimeZones);

  test('academy clock maps a UTC instant to Europe/Rome including day rollover', () {
    // 2026-09-07 22:30 UTC = 2026-09-08 00:30 CEST (UTC+2).
    // US Eastern (UTC-4) is still 2026-09-07 18:30.
    final clock = AcademyClock(now: () => DateTime.utc(2026, 9, 7, 22, 30));
    final now = clock.now();

    expect(now, isA<tz.TZDateTime>());
    expect((now as tz.TZDateTime).location.name, academyTimeZoneName);
    expect(now.year, 2026);
    expect(now.month, 9);
    expect(now.day, 8);
    expect(now.hour, 0);
    expect(now.minute, 30);
    expect(now.timeZoneOffset, const Duration(hours: 2));
  });

  test('Student Home today and next lesson use Rome day, not the device calendar', () {
    final json = publishedScheduleJson();
    (json['days'] as List)[1]['lessons'] = [
      {
        'id': 200,
        'starts_at': '10:00',
        'ends_at': '11:30',
        'title': 'Martedì',
        'status': 'published',
      },
    ];
    final view = ScheduleWeekView.fromJson(json);
    final now = AcademyClock(now: () => DateTime.utc(2026, 9, 7, 22, 30)).now();

    final today = todaysLessons(view, now);
    expect(today, hasLength(1));
    expect(today.single.lesson.title, 'Martedì');
    expect(today.single.day.date.day, 8);

    final next = findNextLesson(view, now);
    expect(next?.lesson.title, 'Martedì');
  });

  test('Europe/Rome uses CEST in summer and CET in winter', () {
    final summer = AcademyClock(now: () => DateTime.utc(2026, 7, 15, 12)).now();
    expect(summer.year, 2026);
    expect(summer.month, 7);
    expect(summer.day, 15);
    expect(summer.hour, 14);
    expect(summer.timeZoneOffset, const Duration(hours: 2));
    expect((summer as tz.TZDateTime).location.name, academyTimeZoneName);

    final winter = AcademyClock(now: () => DateTime.utc(2026, 1, 15, 12)).now();
    expect(winter.year, 2026);
    expect(winter.month, 1);
    expect(winter.day, 15);
    expect(winter.hour, 13);
    expect(winter.timeZoneOffset, const Duration(hours: 1));
    expect((winter as tz.TZDateTime).location.name, academyTimeZoneName);
  });
}
