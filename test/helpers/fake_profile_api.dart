import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/models/auth_device.dart';

class FakeProfileApi extends ProfileApi {
  FakeProfileApi(super.client);

  Object? changePasswordThrow;
  Object? devicesThrow;
  Object? revokeThrow;
  Object? logoutAllThrow;
  int changePasswordCalls = 0;
  int logoutAllCalls = 0;
  int? lastRevokedId;
  List<AuthDevice> deviceList = const [];

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    changePasswordCalls += 1;
    if (changePasswordThrow != null) {
      throw changePasswordThrow!;
    }
  }

  @override
  Future<List<AuthDevice>> devices() async {
    if (devicesThrow != null) {
      throw devicesThrow!;
    }
    return deviceList;
  }

  @override
  Future<void> revokeDevice(int id) async {
    lastRevokedId = id;
    if (revokeThrow != null) {
      throw revokeThrow!;
    }
  }

  @override
  Future<void> logoutAll() async {
    logoutAllCalls += 1;
    if (logoutAllThrow != null) {
      throw logoutAllThrow!;
    }
  }
}
