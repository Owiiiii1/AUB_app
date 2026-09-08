enum AccountType {
  student,
  parent,
  teacher;

  static AccountType? tryParse(String? raw) {
    return switch (raw) {
      'student' => AccountType.student,
      'parent' => AccountType.parent,
      'teacher' => AccountType.teacher,
      _ => null,
    };
  }
}

class ApiUser {
  const ApiUser({
    required this.id,
    required this.name,
    required this.email,
    required this.accountType,
  });

  final int id;
  final String name;
  final String email;
  final AccountType accountType;

  factory ApiUser.fromJson(Map<String, dynamic> json) {
    final type = AccountType.tryParse(json['account_type'] as String?);
    if (type == null) {
      throw const FormatException('Unsupported account type.');
    }
    return ApiUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      accountType: type,
    );
  }
}
