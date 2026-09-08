import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/auth/models/auth_session.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<LoginResult> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    final data = await _client.post(
      '/auth/login',
      body: {
        'email': email,
        'password': password,
        'device_name': deviceName,
      },
      skipAuth: true,
    );
    return LoginResult.fromJson(data);
  }

  Future<MePayload> me() async {
    final data = await _client.get('/me');
    return MePayload.fromJson(data);
  }

  Future<void> logout() {
    return _client.post('/auth/logout');
  }

  Future<void> logoutAll() {
    return _client.post('/auth/logout-all');
  }
}
