enum AttendanceStatus {
  present,
  absent,
  excused;

  static AttendanceStatus parse(String? raw) {
    return switch (raw) {
      'present' => AttendanceStatus.present,
      'absent' => AttendanceStatus.absent,
      'excused' => AttendanceStatus.excused,
      _ => throw const FormatException('Unknown attendance status.'),
    };
  }

  String get apiValue => name;
}

class AttendanceNamedRef {
  const AttendanceNamedRef({required this.id, required this.name});

  final int id;
  final String name;

  factory AttendanceNamedRef.fromJson(Map<String, dynamic> json) {
    return AttendanceNamedRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class AttendanceLocation {
  const AttendanceLocation({this.building, this.room});

  final AttendanceNamedRef? building;
  final AttendanceNamedRef? room;

  factory AttendanceLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const AttendanceLocation();
    }
    return AttendanceLocation(
      building: _refOrNull(json['building']),
      room: _refOrNull(json['room']),
    );
  }
}

class AttendanceLesson {
  const AttendanceLesson({
    required this.id,
    required this.date,
    required this.startsAt,
    required this.endsAt,
    required this.title,
    required this.status,
    this.academyClass,
    this.location,
  });

  final int id;
  final String date;
  final String startsAt;
  final String endsAt;
  final String title;
  final String status;
  final AttendanceNamedRef? academyClass;
  final AttendanceLocation? location;

  factory AttendanceLesson.fromJson(Map<String, dynamic> json) {
    return AttendanceLesson(
      id: json['id'] as int,
      date: json['date'] as String,
      startsAt: json['starts_at'] as String,
      endsAt: json['ends_at'] as String,
      title: json['title'] as String,
      status: json['status'] as String,
      academyClass: _refOrNull(json['academy_class']),
      location: json['location'] is Map
          ? AttendanceLocation.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null,
    );
  }
}

class AttendanceMark {
  const AttendanceMark({required this.status, this.markedAt});

  final AttendanceStatus status;
  final DateTime? markedAt;

  factory AttendanceMark.fromJson(Map<String, dynamic> json) {
    return AttendanceMark(
      status: AttendanceStatus.parse(json['status'] as String?),
      markedAt: json['marked_at'] is String
          ? DateTime.tryParse(json['marked_at'] as String)
          : null,
    );
  }
}

class AttendanceStudent {
  const AttendanceStudent({
    required this.id,
    required this.displayName,
    this.photoUrl,
    this.attendance,
  });

  final int id;
  final String displayName;
  final String? photoUrl;
  final AttendanceMark? attendance;

  factory AttendanceStudent.fromJson(Map<String, dynamic> json) {
    final mark = json['attendance'];
    return AttendanceStudent(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      attendance: mark is Map
          ? AttendanceMark.fromJson(Map<String, dynamic>.from(mark))
          : null,
    );
  }
}

class AttendanceRoster {
  const AttendanceRoster({
    required this.lesson,
    required this.editable,
    required this.students,
    this.reason,
  });

  final AttendanceLesson lesson;
  final bool editable;
  final String? reason;
  final List<AttendanceStudent> students;

  factory AttendanceRoster.fromJson(Map<String, dynamic> json) {
    final lessonJson = json['lesson'];
    final studentsJson = json['students'];
    if (lessonJson is! Map || studentsJson is! List) {
      throw const FormatException('Malformed attendance payload.');
    }
    final students = <AttendanceStudent>[];
    for (final item in studentsJson) {
      if (item is! Map) {
        throw const FormatException('Malformed attendance payload.');
      }
      students.add(
        AttendanceStudent.fromJson(Map<String, dynamic>.from(item)),
      );
    }
    return AttendanceRoster(
      lesson: AttendanceLesson.fromJson(
        Map<String, dynamic>.from(lessonJson),
      ),
      editable: json['attendance_editable'] as bool,
      reason: json['reason'] as String?,
      students: students,
    );
  }
}

AttendanceNamedRef? _refOrNull(dynamic value) {
  if (value is Map) {
    return AttendanceNamedRef.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}
