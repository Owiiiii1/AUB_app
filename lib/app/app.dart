import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/presentation/login_screen.dart';
import 'package:aub/features/auth/presentation/restore_failed_screen.dart';
import 'package:aub/features/auth/presentation/splash_screen.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/auth/state/auth_state.dart';
import 'package:aub/features/home/presentation/parent_home_screen.dart';
import 'package:aub/features/home/presentation/student_home_screen.dart';
import 'package:aub/features/home/presentation/teacher_home_screen.dart';

class AubApp extends StatefulWidget {
  const AubApp({
    super.key,
    required this.controller,
    this.restoreOnStart = true,
  });

  final AuthController controller;
  final bool restoreOnStart;

  @override
  State<AubApp> createState() => _AubAppState();
}

class _AubAppState extends State<AubApp> {
  static const brandColor = Color(0xFF1A2B44);

  @override
  void initState() {
    super.initState();
    if (widget.restoreOnStart) {
      widget.controller.restoreSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: brandColor,
          primary: brandColor,
        ),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: ListenableBuilder(
        listenable: widget.controller,
        builder: (context, _) {
          final state = widget.controller.state;
          return switch (state.status) {
            AuthStatus.initializing => const SplashScreen(),
            AuthStatus.authenticating => LoginScreen(controller: widget.controller),
            AuthStatus.unauthenticated => LoginScreen(controller: widget.controller),
            AuthStatus.restoreFailed => RestoreFailedScreen(
                message: state.errorMessage ?? AppStrings.restoreOffline,
                onRetry: widget.controller.restoreSession,
              ),
            AuthStatus.authenticated => _authenticatedHome(state),
          };
        },
      ),
    );
  }

  Widget _authenticatedHome(AuthState state) {
    final session = state.session;
    if (session == null) {
      return LoginScreen(controller: widget.controller);
    }
    final onLogout = widget.controller.logout;
    return switch (session.profile) {
      StudentProfile profile => StudentHomeScreen(
          profile: profile,
          onLogout: onLogout,
        ),
      ParentProfile profile => ParentHomeScreen(
          profile: profile,
          onLogout: onLogout,
        ),
      TeacherProfile profile => TeacherHomeScreen(
          profile: profile,
          onLogout: onLogout,
        ),
    };
  }
}
