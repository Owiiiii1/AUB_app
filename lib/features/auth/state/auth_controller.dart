import 'package:flutter/foundation.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/auth/data/auth_repository.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/auth/presentation/auth_messages.dart';
import 'package:aub/features/auth/state/auth_state.dart';

class AuthController extends ChangeNotifier {
  AuthController({required AuthRepository repository}) : _repository = repository;

  final AuthRepository _repository;
  AuthState _state = const AuthState.initializing();
  bool _handlingUnauthorized = false;

  AuthState get state => _state;

  Future<void> restoreSession() async {
    _setState(const AuthState.initializing());
    try {
      final session = await _repository.restoreSession();
      if (session == null) {
        _setState(const AuthState.unauthenticated());
        return;
      }
      _acceptSession(session);
    } on ApiException catch (error) {
      if (error.isTransient) {
        _setState(
          const AuthState(
            status: AuthStatus.restoreFailed,
            errorMessage: AppStrings.restoreOffline,
          ),
        );
        return;
      }
      await _repository.clearLocalSession();
      _setState(AuthState.unauthenticated(errorMessage: AuthMessages.forException(error)));
    } on FormatException {
      await _repository.clearLocalSession();
      _setState(
        const AuthState.unauthenticated(errorMessage: AppStrings.unsupportedAccount),
      );
    } catch (_) {
      _setState(
        const AuthState(
          status: AuthStatus.restoreFailed,
          errorMessage: AppStrings.serverError,
        ),
      );
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setState(const AuthState(status: AuthStatus.authenticating));
    try {
      final session = await _repository.login(email: email, password: password);
      _acceptSession(session);
    } on ApiException catch (error) {
      _setState(
        AuthState.unauthenticated(errorMessage: AuthMessages.forException(error)),
      );
    } on FormatException {
      await _repository.clearLocalSession();
      _setState(
        const AuthState.unauthenticated(errorMessage: AppStrings.unsupportedAccount),
      );
    } catch (_) {
      _setState(const AuthState.unauthenticated(errorMessage: AppStrings.serverError));
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _setState(const AuthState.unauthenticated());
  }

  Future<void> handleUnauthorized() async {
    if (_handlingUnauthorized || _state.status == AuthStatus.unauthenticated) {
      return;
    }
    _handlingUnauthorized = true;
    try {
      await _repository.clearLocalSession();
      _setState(const AuthState.unauthenticated(errorMessage: AppStrings.unauthenticated));
    } finally {
      _handlingUnauthorized = false;
    }
  }

  void _acceptSession(AuthSession session) {
    switch (session.user.accountType) {
      case AccountType.student:
      case AccountType.parent:
      case AccountType.teacher:
        _setState(
          AuthState(status: AuthStatus.authenticated, session: session),
        );
    }
  }

  void _setState(AuthState next) {
    _state = next;
    notifyListeners();
  }
}
