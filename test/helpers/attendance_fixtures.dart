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
