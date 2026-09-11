import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_fixtures.dart';

void main() {
  test('parses student /me payload', () {
    final me = MePayload.fromJson(studentMeJson());
    expect(me.user.accountType, AccountType.student);
    expect(me.user.email, 'mario@example.test');
    final profile = me.profile as StudentProfile;
    expect(profile.displayName, 'Mario Rossi');
    expect(profile.academyClass?.name, 'Prima A');
    expect(profile.academicYear?.name, '2026/2027');
    expect(profile.photoUrl, 'https://aub.owlsolutions.net/storage/students/1.jpg');
    expect(profile.phone, '+39 333 120 8801');
    expect(profile.birthDate, '2009-04-18');
    expect(profile.formattedAddress, 'Via Padova 128\n20127 Milano (MI)');
  });

  test('parses parent /me payload with children', () {
    final me = MePayload.fromJson(parentMeJson());
    expect(me.user.accountType, AccountType.parent);
    final profile = me.profile as ParentProfile;
    expect(profile.displayName, 'Maria Verdi');
    expect(profile.children, hasLength(1));
    expect(profile.children.first.displayName, 'Giulia Verdi');
    expect(profile.children.first.academyClass?.name, 'Own Class');
  });

  test('parses teacher /me payload', () {
    final me = MePayload.fromJson(teacherMeJson());
    expect(me.user.accountType, AccountType.teacher);
    final profile = me.profile as TeacherProfile;
    expect(profile.displayName, 'Elena Bianchi');
  });

  test('rejects malformed /me payload', () {
    expect(() => MePayload.fromJson(const {}), throwsFormatException);
    expect(
      () => MePayload.fromJson({
        'user': {'id': 1, 'name': 'X', 'email': 'x@test.it'},
        'profile': {'id': 1, 'display_name': 'X'},
      }),
      throwsFormatException,
    );
  });

  test('rejects staff and unknown account types', () {
    expect(
      () => MePayload.fromJson({
        'user': {
          'id': 1,
          'name': 'Staff',
          'email': 'staff@example.test',
          'account_type': 'staff',
        },
        'profile': {'id': 1, 'display_name': 'Staff'},
      }),
      throwsFormatException,
    );
    expect(AccountType.tryParse('staff'), isNull);
    expect(AccountType.tryParse('unknown'), isNull);
  });
}
