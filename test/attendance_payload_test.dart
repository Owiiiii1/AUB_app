import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/attendance_fixtures.dart';

void main() {
  test('parses roster with existing and unmarked students', () {
    final roster = AttendanceRoster.fromJson(attendanceRosterJson());
    expect(roster.lesson.title, 'Danza classica');
    expect(roster.lesson.academyClass?.name, 'Classe A');
    expect(roster.lesson.startsAt, '16:00');
    expect(roster.lesson.location?.room?.name, 'Sala 2');
    expect(roster.editable, isTrue);
    expect(roster.reason, isNull);
    expect(roster.students, hasLength(2));
    expect(roster.students[0].displayName, 'Anna Rossi');
    expect(roster.students[0].attendance?.status, AttendanceStatus.present);
    expect(roster.students[1].attendance, isNull);
  });

  test('parses cancelled read-only roster', () {
    final roster = AttendanceRoster.fromJson(
      attendanceRosterJson(
        status: 'cancelled',
        editable: false,
        reason: 'cancelled',
      ),
    );
    expect(roster.editable, isFalse);
    expect(roster.reason, 'cancelled');
    expect(roster.lesson.status, 'cancelled');
  });

  test('rejects malformed payload', () {
    expect(() => AttendanceRoster.fromJson(const {}), throwsFormatException);
    expect(
      () => AttendanceRoster.fromJson(
        attendanceRosterJson(
          students: [
            {
              'id': 1,
              'display_name': 'X',
              'attendance': {'status': 'late'},
            },
          ],
        ),
      ),
      throwsFormatException,
    );
  });
}
