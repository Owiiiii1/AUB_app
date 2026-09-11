import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_history_screen.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/home/presentation/student_home_screen.dart';
import 'package:aub/features/home/state/student_home_controller.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/profile/presentation/student_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/shared/widgets/aub_chrome.dart';

class StudentShell extends StatefulWidget {
  const StudentShell({
    super.key,
    required this.profile,
    required this.user,
    required this.onLogout,
    required this.scheduleRepository,
    required this.attendanceHistoryRepository,
    this.homeController,
    this.scheduleController,
    this.attendanceHistoryController,
    this.profileApi,
    this.preferences,
  });

  final StudentProfile profile;
  final ApiUser user;
  final VoidCallback onLogout;
  final ScheduleRepository scheduleRepository;
  final AttendanceHistoryRepository attendanceHistoryRepository;
  final StudentHomeController? homeController;
  final ScheduleController? scheduleController;
  final AttendanceHistoryController? attendanceHistoryController;
  final ProfileApi? profileApi;
  final ProfilePreferences? preferences;

  @override
  State<StudentShell> createState() => _StudentShellState();
}

class _StudentShellState extends State<StudentShell> {
  late final StudentHomeController _homeController;
  late final ScheduleController _scheduleController;
  late final AttendanceHistoryController _historyController;
  StudentNavTab _tab = StudentNavTab.home;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _homeController = widget.homeController ??
        StudentHomeController(
          scheduleRepository: widget.scheduleRepository,
          attendanceHistoryRepository: widget.attendanceHistoryRepository,
        );
    _scheduleController = widget.scheduleController ??
        ScheduleController(repository: widget.scheduleRepository);
    _historyController = widget.attendanceHistoryController ??
        AttendanceHistoryController(
          repository: widget.attendanceHistoryRepository,
        );
    initializeDateFormatting('it').then((_) {
      if (mounted) {
        setState(() => _localeReady = true);
      }
    });
  }

  @override
  void dispose() {
    if (widget.homeController == null) {
      _homeController.dispose();
    }
    if (widget.scheduleController == null) {
      _scheduleController.dispose();
    }
    if (widget.attendanceHistoryController == null) {
      _historyController.dispose();
    }
    super.dispose();
  }

  String get _headerTitle => switch (_tab) {
        StudentNavTab.home => AppStrings.homeTab,
        StudentNavTab.schedule => AppStrings.schedule,
        StudentNavTab.attendance => AppStrings.attendance,
        StudentNavTab.profile => AppStrings.profileTab,
      };

  @override
  Widget build(BuildContext context) {
    if (!_localeReady) {
      return const Scaffold(
        backgroundColor: AubColors.surfaceIvory,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      body: Column(
        children: [
          AubAppHeader(
            title: _headerTitle,
            profile: widget.profile,
            onAvatarTap: () => setState(() => _tab = StudentNavTab.profile),
          ),
          Expanded(
            child: IndexedStack(
              index: _tab.index,
              children: [
                StudentHomeScreen(
                  profile: widget.profile,
                  controller: _homeController,
                  onOpenSchedule: () =>
                      setState(() => _tab = StudentNavTab.schedule),
                  onOpenAttendance: () =>
                      setState(() => _tab = StudentNavTab.attendance),
                  onOpenProfile: () =>
                      setState(() => _tab = StudentNavTab.profile),
                ),
                ScheduleScreen(
                  controller: _scheduleController,
                  embedded: true,
                  studentVisuals: true,
                ),
                AttendanceHistoryScreen(
                  controller: _historyController,
                  embedded: true,
                  studentVisuals: true,
                ),
                StudentProfileScreen(
                  profile: widget.profile,
                  user: widget.user,
                  onLogout: widget.onLogout,
                  profileApi: widget.profileApi,
                  preferences: widget.preferences,
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AubBottomNav(
        selected: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
