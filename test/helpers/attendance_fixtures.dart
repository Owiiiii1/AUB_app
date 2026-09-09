import 'package:aub/features/attendance/models/attendance_models.dart';

Map<String, dynamic> attendanceRosterJson({
  String status = 'published',
  bool editable = true,
  String? reason,
  List<Map<String, dynamic>>? students,
}) {
  return {
    'lesson': {
      'id': 123,
      'date': '2026-09-09',
      'starts_at': '16:00',
      'ends_at': '17:30',
      'title': 'Danza classica',
      'status': status,
      'academy_class': {'id': 5, 'name': 'Classe A'},
      'location': {
        'building': {'id': 1, 'name': 'Sede'},
        'room': {'id': 3, 'name': 'Sala 2'},
      },
    },
    'attendance_editable': editable,
    'reason': reason,
    'students': students ??
        [
          {
            'id': 100,
            'display_name': 'Anna Rossi',
            'photo_url': null,
            'attendance': {
              'status': 'present',
              'marked_at': '2026-09-09T16:15:00+02:00',
            },
          },
          {
            'id': 101,
            'display_name': 'Bruno Neri',
            'photo_url': null,
            'attendance': null,
          },
        ],
  };
}

AttendanceRoster attendanceRoster({
  bool editable = true,
  String? reason,
  String status = 'published',
}) {
  return AttendanceRoster.fromJson(
    attendanceRosterJson(
      editable: editable,
      reason: reason,
      status: status,
    ),
  );
}

Map<String, dynamic> attendanceHistoryJson({
  String month = '2026-09',
  String startsOn = '2026-09-01',
  String endsOn = '2026-09-30',
  int marked = 3,
  int present = 1,
  int absent = 1,
  int excused = 1,
  List<Map<String, dynamic>>? records,
}) {
  return {
    'student': {'id': 8, 'display_name': 'Anna Rossi'},
    'period': {
      'month': month,
      'starts_on': startsOn,
      'ends_on': endsOn,
    },
    'summary': {
      'marked': marked,
      'present': present,
      'absent': absent,
      'excused': excused,
    },
    'records': records ??
        [
          {
            'id': 35,
            'date': '2026-09-09',
            'starts_at': '16:00',
            'ends_at': '17:30',
            'status': 'present',
            'lesson': {'id': 4, 'name': 'Danza classica'},
            'title': 'Danza classica',
            'teacher': {'id': 7, 'display_name': 'Maria Rossi'},
            'location': {
              'building': {'id': 1, 'name': 'Sede centrale'},
              'room': {'id': 2, 'name': 'Sala 2'},
            },
          },
          {
            'id': 34,
            'date': '2026-09-08',
            'starts_at': '16:00',
            'ends_at': '17:30',
            'status': 'absent',
            'lesson': {'id': 4, 'name': 'Danza classica'},
            'title': 'Danza classica',
            'teacher': {'id': 7, 'display_name': 'Maria Rossi'},
            'location': {
              'building': {'id': 1, 'name': 'Sede centrale'},
              'room': {'id': 2, 'name': 'Sala 2'},
            },
          },
          {
            'id': 33,
            'date': '2026-09-07',
            'starts_at': '16:00',
            'ends_at': '17:30',
            'status': 'excused',
            'lesson': {'id': 4, 'name': 'Danza classica'},
            'title': 'Danza classica',
            'teacher': {'id': 7, 'display_name': 'Maria Rossi'},
            'location': {
              'building': {'id': 1, 'name': 'Sede centrale'},
              'room': {'id': 2, 'name': 'Sala 2'},
            },
          },
        ],
  };
}

AttendanceHistory attendanceHistory({
  String month = '2026-09',
  List<Map<String, dynamic>>? records,
  int marked = 3,
  int present = 1,
  int absent = 1,
  int excused = 1,
}) {
  return AttendanceHistory.fromJson(
    attendanceHistoryJson(
      month: month,
      records: records,
      marked: marked,
      present: present,
      absent: absent,
      excused: excused,
    ),
  );
}
