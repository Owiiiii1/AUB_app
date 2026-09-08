import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/auth/state/auth_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_fixtures.dart';

void main() {
  test('no stored token stays unauthenticated', () async {
    final harness = createHarness();
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.controller.state.session, isNull);
    expect(harness.storage.value, isNull);
  });

  test('stored valid token and /me authenticates', () async {
    final harness = createHarness(storedToken: 'stored-token');
    harness.authApi.meJson = studentMeJson();
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.authenticated);
    expect(harness.controller.state.session?.user.email, 'mario@example.test');
    expect(harness.storage.value, 'stored-token');
  });

  test('stored invalid token with 401 is removed', () async {
    final harness = createHarness(storedToken: 'expired-token');
    harness.authApi.meThrow = const ApiException(
      code: ApiErrorCode.unauthenticated,
      message: 'Unauthenticated.',
      statusCode: 401,
    );
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.storage.value, isNull);
  });

  test('stored token with network failure is kept', () async {
    final harness = createHarness(storedToken: 'offline-token');
    harness.authApi.meThrow = const ApiException(
      code: ApiErrorCode.network,
      message: 'offline',
    );
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.restoreFailed);
    expect(harness.storage.value, 'offline-token');
    expect(harness.controller.state.errorMessage, AppStrings.restoreOffline);
  });

  test('login success stores token then authenticates from /me', () async {
    final harness = createHarness();
    harness.authApi.loginResult = LoginResult(
      token: 'new-token',
      tokenType: 'Bearer',
      expiresAt: DateTime.utc(2026, 10, 8),
    );
    harness.authApi.meJson = studentMeJson();
    await harness.controller.login(
      email: 'mario@example.test',
      password: 'secret',
    );
    expect(harness.controller.state.status, AuthStatus.authenticated);
    expect(harness.storage.value, 'new-token');
    expect(harness.authApi.lastDeviceName, 'AUB Test');
  });

  test('login failure does not store a token', () async {
    final harness = createHarness();
    harness.authApi.loginThrow = const ApiException(
      code: ApiErrorCode.invalidCredentials,
      message: 'Invalid credentials.',
      statusCode: 401,
    );
    await harness.controller.login(
      email: 'mario@example.test',
      password: 'wrong',
    );
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.controller.state.errorMessage, AppStrings.invalidCredentials);
    expect(harness.storage.value, isNull);
  });

  test('unsupported actor is not authenticated and token is cleared', () async {
    final harness = createHarness();
    harness.authApi.loginResult = const LoginResult(
      token: 'staff-token',
      tokenType: 'Bearer',
    );
    harness.authApi.meJson = {
      'user': {
        'id': 99,
        'name': 'Staff',
        'email': 'staff@example.test',
        'account_type': 'staff',
      },
      'profile': {'id': 1, 'display_name': 'Staff'},
    };
    await harness.controller.login(
      email: 'staff@example.test',
      password: 'secret',
    );
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.controller.state.errorMessage, AppStrings.unsupportedAccount);
    expect(harness.storage.value, isNull);
  });

  test('restoring an unsupported actor is not authenticated', () async {
    final harness = createHarness(storedToken: 'staff-token');
    harness.authApi.meJson = {
      'user': {
        'id': 99,
        'name': 'Staff',
        'email': 'staff@example.test',
        'account_type': 'staff',
      },
      'profile': {'id': 1, 'display_name': 'Staff'},
    };
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.storage.value, isNull);
  });

  test('logout removes the token even if the server call fails', () async {
    final harness = createHarness(storedToken: 'stored-token');
    harness.authApi.meJson = teacherMeJson();
    await harness.controller.restoreSession();
    expect(harness.controller.state.status, AuthStatus.authenticated);

    harness.authApi.logoutThrow = const ApiException(
      code: ApiErrorCode.network,
      message: 'offline',
    );
    await harness.controller.logout();
    expect(harness.controller.state.status, AuthStatus.unauthenticated);
    expect(harness.storage.value, isNull);
    expect(harness.authApi.logoutCalls, 1);
  });
}
