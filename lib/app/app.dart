import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/media/api_client_scope.dart';
import 'package:aub/app/theme/aub_theme.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/presentation/login_screen.dart';
import 'package:aub/features/auth/presentation/restore_failed_screen.dart';
import 'package:aub/features/auth/presentation/splash_screen.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/auth/state/auth_state.dart';
import 'package:aub/features/home/presentation/parent_shell.dart';
import 'package:aub/features/home/presentation/student_shell.dart';
import 'package:aub/features/home/presentation/teacher_shell.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';

class AubApp extends StatefulWidget {
  const AubApp({
    super.key,
    required this.controller,
    required this.scheduleRepository,
    required this.attendanceRepository,
    required this.attendanceHistoryRepository,
    this.profileApi,
    this.profilePreferences,
    this.restoreOnStart = true,
  });

  final AuthController controller;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final AttendanceHistoryRepository attendanceHistoryRepository;
  final ProfileApi? profileApi;
  final ProfilePreferences? profilePreferences;
  final bool restoreOnStart;

  @override
  State<AubApp> createState() => _AubAppState();
}

class _AubAppState extends State<AubApp> {
  @override
  void initState() {
    super.initState();
    if (widget.restoreOnStart) {
      widget.controller.restoreSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApiClientScope(
      client: widget.controller.apiClient,
      child: MaterialApp(
      title: AppStrings.appName,
      theme: buildAubTheme(),
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
            AuthStatus.authenticated => _authenticatedHome(context, state),
          };
        },
      ),
      ),
    );
  }

  Widget _authenticatedHome(BuildContext context, AuthState state) {
    final session = state.session;
    if (session == null) {
      return LoginScreen(controller: widget.controller);
    }
    final onLogout = widget.controller.logout;
    return switch (session.profile) {
      StudentProfile profile => StudentShell(
          profile: profile,
          user: session.user,
          onLogout: onLogout,
          scheduleRepository: widget.scheduleRepository,
          attendanceHistoryRepository: widget.attendanceHistoryRepository,
          profileApi: widget.profileApi,
          preferences: widget.profilePreferences,
        ),
      ParentProfile profile => ParentShell(
          profile: profile,
          user: session.user,
          onLogout: onLogout,
          scheduleRepository: widget.scheduleRepository,
          attendanceHistoryRepository: widget.attendanceHistoryRepository,
          profileApi: widget.profileApi,
          preferences: widget.profilePreferences,
        ),
      TeacherProfile profile => TeacherShell(
          profile: profile,
          user: session.user,
          onLogout: onLogout,
          scheduleRepository: widget.scheduleRepository,
          attendanceRepository: widget.attendanceRepository,
          profileApi: widget.profileApi,
          preferences: widget.profilePreferences,
        ),
    };
  }
}
