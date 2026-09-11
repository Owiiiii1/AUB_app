import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/profile/models/auth_device.dart';

class ProfileApi {
  ProfileApi(this._client);

  final ApiClient _client;

  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    await _client.put(
      '/me/password',
      body: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
  }

  Future<List<AuthDevice>> devices() async {
    final data = await _client.get('/me/devices');
    final raw = data['devices'];
    if (raw is! List) {
      return const [];
    }
    return [
      for (final item in raw)
        if (item is Map)
          AuthDevice.fromJson(Map<String, dynamic>.from(item)),
    ];
  }

  Future<void> revokeDevice(int id) {
    return _client.delete('/me/devices/$id');
  }

  Future<void> logoutAll() {
    return _client.post('/auth/logout-all');
  }
}
