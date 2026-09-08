import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aub/core/storage/token_storage.dart';

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  static const tokenKey = 'aub_access_token';

  final FlutterSecureStorage _storage;

  @override
  Future<String?> readToken() {
    return _storage.read(key: tokenKey);
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() {
    return _storage.delete(key: tokenKey);
  }
}
