Map<String, dynamic> publishedScheduleJson({
  String status = 'published',
  String title = 'Danza classica',
  String startsAt = '16:00',
  String endsAt = '17:30',
}) {
  return {
    'student': {
      'id': 10,
      'display_name': 'Mario Rossi',
      'academy_class': {'id': 3, 'name': 'Classe A'},
    },
    'week': {
      'starts_on': '2026-09-07',
      'ends_on': '2026-09-13',
      'published': true,
    },
    'days': [
      {
        'date': '2026-09-07',
        'weekday': 1,
        'lessons': [
          {
            'id': 100,
            'starts_at': startsAt,
            'ends_at': endsAt,
            'title': title,
            'lesson': {'id': 4, 'name': 'Danza classica'},
            'teacher': {'id': 8, 'display_name': 'Maria Rossi'},
            'location': {
              'building': {'id': 1, 'name': 'SEDE ACCADEMIA'},
              'room': {'id': 4, 'name': 'Sala 2'},
            },
            'status': status,
          },
        ],
      },
      for (var i = 1; i < 7; i++)
        {
          'date': '2026-09-${(7 + i).toString().padLeft(2, '0')}',
          'weekday': i + 1,
          'lessons': <Map<String, dynamic>>[],
        },
    ],
    'empty_reason': null,
  };
}

Map<String, dynamic> unpublishedScheduleJson() {
  return {
    'student': {
      'id': 10,
      'display_name': 'Mario Rossi',
      'academy_class': {'id': 3, 'name': 'Classe A'},
    },
    'week': {
      'starts_on': '2026-09-07',
      'ends_on': '2026-09-13',
      'published': false,
    },
    'days': [
      for (var i = 0; i < 7; i++)
        {
          'date': '2026-09-${(7 + i).toString().padLeft(2, '0')}',
          'weekday': i + 1,
          'lessons': <Map<String, dynamic>>[],
        },
    ],
    'empty_reason': 'unpublished',
  };
}

Map<String, dynamic> emptyClassScheduleJson() {
  return {
    'student': {
      'id': 10,
      'display_name': 'Mario Rossi',
      'academy_class': null,
    },
    'week': {
      'starts_on': '2026-09-07',
      'ends_on': '2026-09-13',
      'published': false,
    },
    'days': <Map<String, dynamic>>[],
    'empty_reason': 'no_class',
  };
}
