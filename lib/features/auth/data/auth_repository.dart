import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/platform/device_name.dart';
import 'package:aub/core/storage/token_storage.dart';
import 'package:aub/features/auth/data/auth_api.dart';
import 'package:aub/features/auth/models/auth_session.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
    AuthApi? authApi,
    String Function()? deviceName,
  })  : _apiClient = apiClient,
        _tokenStorage = tokenStorage,
        _authApi = authApi ?? AuthApi(apiClient),
        _deviceName = deviceName ?? defaultDeviceName;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final AuthApi _authApi;
  final String Function() _deviceName;

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final login = await _authApi.login(
      email: email,
      password: password,
      deviceName: _deviceName(),
    );
    await _tokenStorage.writeToken(login.token);
    _apiClient.setAccessToken(login.token);
    try {
      final me = await _authApi.me();
      return AuthSession(
        user: me.user,
        profile: me.profile,
        expiresAt: login.expiresAt,
      );
    } catch (_) {
      await clearLocalSession();
      rethrow;
    }
  }

  Future<AuthSession?> restoreSession() async {
    final token = await _tokenStorage.readToken();
    if (token == null || token.isEmpty) {
      _apiClient.clearAccessToken();
      return null;
    }

    _apiClient.setAccessToken(token);
    try {
      final me = await _authApi.me();
      return AuthSession(user: me.user, profile: me.profile);
    } on ApiException catch (error) {
      if (error.isUnauthorized) {
        await clearLocalSession();
        return null;
      }
      rethrow;
    } on FormatException {
      await clearLocalSession();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (_) {
      // Local logout must succeed even if the network call fails.
    } finally {
      await clearLocalSession();
    }
  }

  Future<void> clearLocalSession() async {
    _apiClient.clearAccessToken();
    await _tokenStorage.deleteToken();
  }
}
