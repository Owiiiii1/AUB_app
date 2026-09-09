import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/attendance_fixtures.dart';

void main() {
  test('parses present absent excused summary and records', () {
    final history = AttendanceHistory.fromJson(attendanceHistoryJson());
    expect(history.student.displayName, 'Anna Rossi');
    expect(history.period.month, '2026-09');
    expect(history.period.startsOn, '2026-09-01');
    expect(history.period.endsOn, '2026-09-30');
    expect(history.summary.marked, 3);
    expect(history.summary.present, 1);
    expect(history.summary.absent, 1);
    expect(history.summary.excused, 1);
    expect(history.records, hasLength(3));
    expect(history.records[0].status, AttendanceStatus.present);
    expect(history.records[1].status, AttendanceStatus.absent);
    expect(history.records[2].status, AttendanceStatus.excused);
    expect(history.records[0].teacher?.displayName, 'Maria Rossi');
    expect(history.records[0].location?.room?.name, 'Sala 2');
    expect(history.records[0].title, 'Danza classica');
  });

  test('parses empty history', () {
    final history = AttendanceHistory.fromJson(
      attendanceHistoryJson(
        marked: 0,
        present: 0,
        absent: 0,
        excused: 0,
        records: const [],
      ),
    );
    expect(history.records, isEmpty);
    expect(history.summary.marked, 0);
  });

  test('rejects malformed history payload', () {
    expect(() => AttendanceHistory.fromJson(const {}), throwsFormatException);
    expect(
      () => AttendanceHistory.fromJson(
        attendanceHistoryJson(
          records: [
            {
              'id': 1,
              'date': '2026-09-09',
              'starts_at': '16:00',
              'ends_at': '17:00',
              'status': 'late',
              'title': 'X',
            },
          ],
        ),
      ),
      throwsFormatException,
    );
  });
}
