import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';

class AuthSession {
  const AuthSession({
    required this.user,
    required this.profile,
    this.expiresAt,
  });

  final ApiUser user;
  final ActorProfile profile;
  final DateTime? expiresAt;
}

class MePayload {
  const MePayload({required this.user, required this.profile});

  final ApiUser user;
  final ActorProfile profile;

  factory MePayload.fromJson(Map<String, dynamic> json) {
    final userJson = json['user'];
    final profileJson = json['profile'];
    if (userJson is! Map || profileJson is! Map) {
      throw const FormatException('Malformed /me payload.');
    }

    final user = ApiUser.fromJson(Map<String, dynamic>.from(userJson));
    final profileMap = Map<String, dynamic>.from(profileJson);
    final profile = switch (user.accountType) {
      AccountType.student => StudentProfile.fromJson(profileMap),
      AccountType.parent => ParentProfile.fromJson(profileMap),
      AccountType.teacher => TeacherProfile.fromJson(profileMap),
    };

    return MePayload(user: user, profile: profile);
  }
}

class LoginResult {
  const LoginResult({
    required this.token,
    required this.tokenType,
    this.expiresAt,
  });

  final String token;
  final String tokenType;
  final DateTime? expiresAt;

  factory LoginResult.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String?;
    if (token == null || token.isEmpty) {
      throw const FormatException('Login response missing token.');
    }
    DateTime? expiresAt;
    final rawExpires = json['expires_at'] as String?;
    if (rawExpires != null && rawExpires.isNotEmpty) {
      expiresAt = DateTime.tryParse(rawExpires);
    }
    return LoginResult(
      token: token,
      tokenType: (json['token_type'] as String?) ?? 'Bearer',
      expiresAt: expiresAt,
    );
  }
}
