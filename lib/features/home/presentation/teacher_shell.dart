import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_screen.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/home/presentation/teacher_home_screen.dart';
import 'package:aub/features/home/presentation/teacher_presenze_screen.dart';
import 'package:aub/features/home/state/teacher_home_controller.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/profile/presentation/teacher_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/shared/widgets/aub_chrome.dart';

class TeacherShell extends StatefulWidget {
  const TeacherShell({
    super.key,
    required this.profile,
    required this.user,
    required this.onLogout,
    required this.scheduleRepository,
    required this.attendanceRepository,
    this.homeController,
    this.scheduleController,
    this.profileApi,
    this.preferences,
    this.clock = const AcademyClock(),
  });

  final TeacherProfile profile;
  final ApiUser user;
  final VoidCallback onLogout;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final TeacherHomeController? homeController;
  final ScheduleController? scheduleController;
  final ProfileApi? profileApi;
  final ProfilePreferences? preferences;
  final AcademyClock clock;

  @override
  State<TeacherShell> createState() => _TeacherShellState();
}

class _TeacherShellState extends State<TeacherShell> {
  late final TeacherHomeController _homeController;
  late final ScheduleController _scheduleController;
  TeacherNavTab _tab = TeacherNavTab.today;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _homeController = widget.homeController ??
        TeacherHomeController(
          scheduleRepository: widget.scheduleRepository,
          clock: widget.clock,
        );
    _scheduleController = widget.scheduleController ??
        ScheduleController(
          repository: widget.scheduleRepository,
          kind: ScheduleKind.teacher,
          clock: widget.clock,
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
    super.dispose();
  }

  String get _headerTitle => switch (_tab) {
        TeacherNavTab.today => AppStrings.today,
        TeacherNavTab.schedule => AppStrings.schedule,
        TeacherNavTab.attendance => AppStrings.attendance,
        TeacherNavTab.profile => AppStrings.profileTab,
      };

  Future<void> _openAttendance(ScheduleLesson lesson) async {
    final controller = AttendanceController(
      repository: widget.attendanceRepository,
      lessonId: lesson.id,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceScreen(controller: controller),
      ),
    );
    controller.dispose();
  }

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
      appBar: AubAppHeader(
        title: _headerTitle,
        mark: AppStrings.teacherMark,
        avatarName: widget.profile.displayName,
        onAvatarTap: () => setState(() => _tab = TeacherNavTab.profile),
      ),
      body: IndexedStack(
        index: _tab.index,
        children: [
          TeacherHomeScreen(
            profile: widget.profile,
            controller: _homeController,
            onOpenAttendance: _openAttendance,
            onOpenSchedule: () =>
                setState(() => _tab = TeacherNavTab.schedule),
          ),
          ScheduleScreen(
            controller: _scheduleController,
            embedded: true,
            studentVisuals: true,
            onLessonTap: _openAttendance,
          ),
          TeacherPresenzeScreen(
            controller: _homeController,
            onOpenAttendance: _openAttendance,
          ),
          TeacherProfileScreen(
            profile: widget.profile,
            user: widget.user,
            onLogout: widget.onLogout,
            profileApi: widget.profileApi,
            preferences: widget.preferences,
          ),
        ],
      ),
      bottomNavigationBar: TeacherBottomNav(
        selected: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}
