import 'package:aub/core/time/date_only.dart';

enum ScheduleLessonStatus {
  published,
  cancelled,
  moved;

  static ScheduleLessonStatus parse(String? raw) {
    return switch (raw) {
      'cancelled' => ScheduleLessonStatus.cancelled,
      'moved' => ScheduleLessonStatus.moved,
      'published' => ScheduleLessonStatus.published,
      _ => throw const FormatException('Unknown lesson status.'),
    };
  }
}

class ScheduleNamedRef {
  const ScheduleNamedRef({required this.id, required this.name});

  final int id;
  final String name;

  factory ScheduleNamedRef.fromJson(Map<String, dynamic> json) {
    return ScheduleNamedRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

class ScheduleTeacherRef {
  const ScheduleTeacherRef({required this.id, required this.displayName});

  final int id;
  final String displayName;

  factory ScheduleTeacherRef.fromJson(Map<String, dynamic> json) {
    return ScheduleTeacherRef(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
    );
  }
}

class ScheduleLocation {
  const ScheduleLocation({this.building, this.room});

  final ScheduleNamedRef? building;
  final ScheduleNamedRef? room;

  factory ScheduleLocation.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ScheduleLocation();
    }
    return ScheduleLocation(
      building: _refOrNull(json['building']),
      room: _refOrNull(json['room']),
    );
  }
}

class ScheduleLesson {
  const ScheduleLesson({
    required this.id,
    required this.startsAt,
    required this.endsAt,
    required this.title,
    required this.status,
    this.lesson,
    this.teacher,
    this.academyClass,
    this.location,
  });

  final int id;
  final String startsAt;
  final String endsAt;
  final String title;
  final ScheduleLessonStatus status;
  final ScheduleNamedRef? lesson;
  final ScheduleTeacherRef? teacher;
  final ScheduleNamedRef? academyClass;
  final ScheduleLocation? location;

  factory ScheduleLesson.fromJson(Map<String, dynamic> json) {
    return ScheduleLesson(
      id: json['id'] as int,
      startsAt: json['starts_at'] as String,
      endsAt: json['ends_at'] as String,
      title: json['title'] as String,
      status: ScheduleLessonStatus.parse(json['status'] as String?),
      lesson: _refOrNull(json['lesson']),
      teacher: json['teacher'] is Map
          ? ScheduleTeacherRef.fromJson(Map<String, dynamic>.from(json['teacher'] as Map))
          : null,
      academyClass: _refOrNull(json['academy_class']),
      location: json['location'] is Map
          ? ScheduleLocation.fromJson(Map<String, dynamic>.from(json['location'] as Map))
          : null,
    );
  }
}

class ScheduleDay {
  const ScheduleDay({
    required this.date,
    required this.weekday,
    required this.lessons,
  });

  final DateTime date;
  final int weekday;
  final List<ScheduleLesson> lessons;

  factory ScheduleDay.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessons'];
    final lessons = <ScheduleLesson>[];
    if (rawLessons is List) {
      for (final item in rawLessons) {
        if (item is Map) {
          lessons.add(ScheduleLesson.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ScheduleDay(
      date: parseDateOnly(json['date'] as String),
      weekday: json['weekday'] as int,
      lessons: lessons,
    );
  }
}

class ScheduleStudent {
  const ScheduleStudent({
    required this.id,
    required this.displayName,
    this.academyClass,
  });

  final int id;
  final String displayName;
  final ScheduleNamedRef? academyClass;

  factory ScheduleStudent.fromJson(Map<String, dynamic> json) {
    return ScheduleStudent(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      academyClass: _refOrNull(json['academy_class']),
    );
  }
}

class ScheduleWeekInfo {
  const ScheduleWeekInfo({
    required this.startsOn,
    required this.endsOn,
    required this.published,
  });

  final DateTime startsOn;
  final DateTime endsOn;
  final bool published;

  factory ScheduleWeekInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleWeekInfo(
      startsOn: parseDateOnly(json['starts_on'] as String),
      endsOn: parseDateOnly(json['ends_on'] as String),
      published: json['published'] as bool,
    );
  }
}

enum ScheduleEmptyReason {
  none,
  noClass,
  unpublished,
  noLessons;

  static ScheduleEmptyReason parse(String? raw) {
    return switch (raw) {
      null => ScheduleEmptyReason.none,
      'no_class' => ScheduleEmptyReason.noClass,
      'unpublished' => ScheduleEmptyReason.unpublished,
      'no_lessons' => ScheduleEmptyReason.noLessons,
      _ => throw const FormatException('Unknown empty_reason.'),
    };
  }
}

class ScheduleWeekView {
  const ScheduleWeekView({
    required this.week,
    required this.days,
    required this.emptyReason,
    this.student,
    this.teacher,
  });

  final ScheduleStudent? student;
  final ScheduleTeacherRef? teacher;
  final ScheduleWeekInfo week;
  final List<ScheduleDay> days;
  final ScheduleEmptyReason emptyReason;

  factory ScheduleWeekView.fromJson(Map<String, dynamic> json) {
    final studentJson = json['student'];
    final teacherJson = json['teacher'];
    final weekJson = json['week'];
    if (weekJson is! Map) {
      throw const FormatException('Malformed schedule payload.');
    }
    if (studentJson is! Map && teacherJson is! Map) {
      throw const FormatException('Malformed schedule payload.');
    }
    final rawDays = json['days'];
    final days = <ScheduleDay>[];
    if (rawDays is List) {
      for (final item in rawDays) {
        if (item is Map) {
          days.add(ScheduleDay.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ScheduleWeekView(
      student: studentJson is Map
          ? ScheduleStudent.fromJson(Map<String, dynamic>.from(studentJson))
          : null,
      teacher: teacherJson is Map
          ? ScheduleTeacherRef.fromJson(Map<String, dynamic>.from(teacherJson))
          : null,
      week: ScheduleWeekInfo.fromJson(Map<String, dynamic>.from(weekJson)),
      days: days,
      emptyReason: ScheduleEmptyReason.parse(json['empty_reason'] as String?),
    );
  }
}

ScheduleNamedRef? _refOrNull(dynamic value) {
  if (value is Map) {
    return ScheduleNamedRef.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}
