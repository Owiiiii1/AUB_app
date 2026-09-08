import 'package:aub/features/auth/data/auth_api.dart';
import 'package:aub/features/auth/models/auth_session.dart';

class FakeAuthApi extends AuthApi {
  FakeAuthApi(super.client);

  LoginResult? loginResult;
  Object? loginThrow;
  MePayload? meResult;
  Map<String, dynamic>? meJson;
  Object? meThrow;
  Object? logoutThrow;
  int logoutCalls = 0;
  String? lastDeviceName;

  @override
  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    lastDeviceName = deviceName;
    if (loginThrow != null) {
      throw loginThrow!;
    }
    return loginResult!;
  }

  @override
  Future<MePayload> me() async {
    if (meThrow != null) {
      throw meThrow!;
    }
    if (meJson != null) {
      return MePayload.fromJson(meJson!);
    }
    return meResult!;
  }

  @override
  Future<void> logout() async {
    logoutCalls += 1;
    if (logoutThrow != null) {
      throw logoutThrow!;
    }
  }
}
