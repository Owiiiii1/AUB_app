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

class AttendancePersonRef {
  const AttendancePersonRef({required this.id, required this.displayName});

  final int id;
  final String displayName;

  factory AttendancePersonRef.fromJson(Map<String, dynamic> json) {
    return AttendancePersonRef(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
    );
  }
}

class AttendancePeriod {
  const AttendancePeriod({
    required this.month,
    required this.startsOn,
    required this.endsOn,
  });

  final String month;
  final String startsOn;
  final String endsOn;

  factory AttendancePeriod.fromJson(Map<String, dynamic> json) {
    return AttendancePeriod(
      month: json['month'] as String,
      startsOn: json['starts_on'] as String,
      endsOn: json['ends_on'] as String,
    );
  }
}

class AttendanceSummary {
  const AttendanceSummary({
    required this.marked,
    required this.present,
    required this.absent,
    required this.excused,
  });

  final int marked;
  final int present;
  final int absent;
  final int excused;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      marked: json['marked'] as int,
      present: json['present'] as int,
      absent: json['absent'] as int,
      excused: json['excused'] as int,
    );
  }
}

class AttendanceHistoryRecord {
  const AttendanceHistoryRecord({
    required this.id,
    required this.date,
    required this.startsAt,
    required this.endsAt,
    required this.status,
    required this.title,
    this.lesson,
    this.teacher,
    this.location,
  });

  final int id;
  final String date;
  final String startsAt;
  final String endsAt;
  final AttendanceStatus status;
  final String title;
  final AttendanceNamedRef? lesson;
  final AttendancePersonRef? teacher;
  final AttendanceLocation? location;

  factory AttendanceHistoryRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceHistoryRecord(
      id: json['id'] as int,
      date: json['date'] as String,
      startsAt: json['starts_at'] as String,
      endsAt: json['ends_at'] as String,
      status: AttendanceStatus.parse(json['status'] as String?),
      title: json['title'] as String,
      lesson: _refOrNull(json['lesson']),
      teacher: json['teacher'] is Map
          ? AttendancePersonRef.fromJson(
              Map<String, dynamic>.from(json['teacher'] as Map),
            )
          : null,
      location: json['location'] is Map
          ? AttendanceLocation.fromJson(
              Map<String, dynamic>.from(json['location'] as Map),
            )
          : null,
    );
  }
}

class AttendanceHistory {
  const AttendanceHistory({
    required this.student,
    required this.period,
    required this.summary,
    required this.records,
  });

  final AttendancePersonRef student;
  final AttendancePeriod period;
  final AttendanceSummary summary;
  final List<AttendanceHistoryRecord> records;

  factory AttendanceHistory.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'];
    final periodJson = json['period'];
    final summaryJson = json['summary'];
    final recordsJson = json['records'];
    if (studentJson is! Map ||
        periodJson is! Map ||
        summaryJson is! Map ||
        recordsJson is! List) {
      throw const FormatException('Malformed attendance history payload.');
    }
    final records = <AttendanceHistoryRecord>[];
    for (final item in recordsJson) {
      if (item is! Map) {
        throw const FormatException('Malformed attendance history payload.');
      }
      records.add(
        AttendanceHistoryRecord.fromJson(Map<String, dynamic>.from(item)),
      );
    }
    return AttendanceHistory(
      student: AttendancePersonRef.fromJson(
        Map<String, dynamic>.from(studentJson),
      ),
      period: AttendancePeriod.fromJson(
        Map<String, dynamic>.from(periodJson),
      ),
      summary: AttendanceSummary.fromJson(
        Map<String, dynamic>.from(summaryJson),
      ),
      records: records,
    );
  }
}

