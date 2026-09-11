import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePreferences {
  ProfilePreferences({FlutterSecureStorage? storage}) : _storage = storage;

  static const languageKey = 'aub_language';
  static const pushKey = 'aub_push_enabled';

  final FlutterSecureStorage? _storage;

  String language = 'it';
  bool pushEnabled = true;

  Future<void> load() async {
    final storage = _storage;
    if (storage == null) {
      return;
    }
    language = await storage.read(key: languageKey) ?? 'it';
    final push = await storage.read(key: pushKey);
    pushEnabled = push != '0';
  }

  Future<void> setLanguage(String value) async {
    language = value;
    await _storage?.write(key: languageKey, value: value);
  }

  Future<void> setPushEnabled(bool value) async {
    pushEnabled = value;
    await _storage?.write(key: pushKey, value: value ? '1' : '0');
  }
}
