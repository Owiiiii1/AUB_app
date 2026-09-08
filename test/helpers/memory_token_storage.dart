import 'dart:async';

import 'package:aub/core/storage/token_storage.dart';

class MemoryTokenStorage implements TokenStorage {
  MemoryTokenStorage([this.value]);

  String? value;

  @override
  Future<String?> readToken() async => value;

  @override
  Future<void> writeToken(String token) async {
    value = token;
  }

  @override
  Future<void> deleteToken() async {
    value = null;
  }
}

class PendingTokenStorage implements TokenStorage {
  final Completer<String?> _read = Completer<String?>();

  @override
  Future<String?> readToken() => _read.future;

  @override
  Future<void> writeToken(String token) async {}

  @override
  Future<void> deleteToken() async {}
}
