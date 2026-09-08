class NamedRef {
  const NamedRef({required this.id, required this.name});

  final int id;
  final String name;

  factory NamedRef.fromJson(Map<String, dynamic> json) {
    return NamedRef(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}

sealed class ActorProfile {
  const ActorProfile();

  String get displayName;
}

class StudentProfile extends ActorProfile {
  const StudentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.photoUrl,
    this.academyClass,
    this.academicYear,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  @override
  final String displayName;
  final String? photoUrl;
  final NamedRef? academyClass;
  final NamedRef? academicYear;

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String,
      photoUrl: json['photo_url'] as String?,
      academyClass: _namedRefOrNull(json['academy_class']),
      academicYear: _namedRefOrNull(json['academic_year']),
    );
  }
}

class ParentChild {
  const ParentChild({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    this.academyClass,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  final String displayName;
  final NamedRef? academyClass;

  factory ParentChild.fromJson(Map<String, dynamic> json) {
    return ParentChild(
      id: json['id'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String,
      academyClass: _namedRefOrNull(json['academy_class']),
    );
  }
}

class ParentProfile extends ActorProfile {
  const ParentProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.children,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  @override
  final String displayName;
  final List<ParentChild> children;

  factory ParentProfile.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['children'];
    final children = <ParentChild>[];
    if (rawChildren is List) {
      for (final item in rawChildren) {
        if (item is Map) {
          children.add(ParentChild.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ParentProfile(
      id: json['id'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String,
      children: children,
    );
  }
}

class TeacherProfile extends ActorProfile {
  const TeacherProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.displayName,
  });

  final int id;
  final String? firstName;
  final String? lastName;
  @override
  final String displayName;

  factory TeacherProfile.fromJson(Map<String, dynamic> json) {
    return TeacherProfile(
      id: json['id'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      displayName: json['display_name'] as String,
    );
  }
}

NamedRef? _namedRefOrNull(dynamic value) {
  if (value is Map) {
    return NamedRef.fromJson(Map<String, dynamic>.from(value));
  }
  return null;
}
