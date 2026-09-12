import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_history_screen.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/home/presentation/parent_children_screen.dart';
import 'package:aub/features/home/presentation/parent_home_screen.dart';
import 'package:aub/features/home/state/parent_home_controller.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/profile/presentation/parent_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/shared/widgets/aub_chrome.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/child_context_header.dart';
import 'package:aub/shared/widgets/child_switcher.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({
    super.key,
    required this.profile,
    required this.user,
    required this.onLogout,
    required this.scheduleRepository,
    required this.attendanceHistoryRepository,
    this.homeController,
    this.scheduleController,
    this.profileApi,
    this.preferences,
    this.clock = const AcademyClock(),
  });

  final ParentProfile profile;
  final ApiUser user;
  final VoidCallback onLogout;
  final ScheduleRepository scheduleRepository;
  final AttendanceHistoryRepository attendanceHistoryRepository;
  final ParentHomeController? homeController;
  final ScheduleController? scheduleController;
  final ProfileApi? profileApi;
  final ProfilePreferences? preferences;
  final AcademyClock clock;

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  late final ParentHomeController _homeController;
  late final ScheduleController _scheduleController;
  late int? _selectedChildId;
  ParentNavTab _tab = ParentNavTab.home;
  bool _localeReady = false;

  @override
  void initState() {
    super.initState();
    _selectedChildId = widget.profile.children.isEmpty
        ? null
        : widget.profile.children.first.id;
    _homeController = widget.homeController ??
        ParentHomeController(
          children: widget.profile.children,
          scheduleRepository: widget.scheduleRepository,
          attendanceHistoryRepository: widget.attendanceHistoryRepository,
          clock: widget.clock,
        );
    _scheduleController = widget.scheduleController ??
        ScheduleController(
          repository: widget.scheduleRepository,
          kind: ScheduleKind.child,
          studentId: _selectedChildId,
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

  ParentChild? get _selectedChild {
    for (final child in widget.profile.children) {
      if (child.id == _selectedChildId) {
        return child;
      }
    }
    return widget.profile.children.isEmpty
        ? null
        : widget.profile.children.first;
  }

  String get _headerTitle => switch (_tab) {
        ParentNavTab.home => AppStrings.homeTab,
        ParentNavTab.children => AppStrings.childrenTab,
        ParentNavTab.calendar => AppStrings.calendarTab,
        ParentNavTab.profile => AppStrings.profileTab,
      };

  void _selectChild(ParentChild child, {ParentNavTab? tab}) {
    setState(() {
      _selectedChildId = child.id;
      if (tab != null) {
        _tab = tab;
      }
    });
    _scheduleController.bindStudent(child.id);
  }

  Future<void> _openAttendance(ParentChild child) async {
    _selectChild(child);
    final controller = AttendanceHistoryController(
      repository: widget.attendanceHistoryRepository,
      studentId: child.id,
    );
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AttendanceHistoryScreen(
          controller: controller,
          childName: child.displayName,
          studentVisuals: true,
        ),
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

    final selected = _selectedChild;

    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      appBar: AubAppHeader(
        title: _headerTitle,
        avatarName: widget.profile.displayName,
        onAvatarTap: () => setState(() => _tab = ParentNavTab.profile),
      ),
      body: IndexedStack(
        index: _tab.index,
        children: [
          ParentHomeScreen(
            profile: widget.profile,
            controller: _homeController,
            onSelectChild: (child) =>
                _selectChild(child, tab: ParentNavTab.children),
            onOpenChildSchedule: (child) =>
                _selectChild(child, tab: ParentNavTab.calendar),
            onOpenChildAttendance: _openAttendance,
            onOpenCalendar: () =>
                setState(() => _tab = ParentNavTab.calendar),
          ),
          ParentChildrenScreen(
            profile: widget.profile,
            controller: _homeController,
            selectedChildId: _selectedChildId,
            onSelectChild: _selectChild,
            onOpenSchedule: (child) =>
                _selectChild(child, tab: ParentNavTab.calendar),
            onOpenAttendance: _openAttendance,
          ),
          _CalendarTab(
            children: widget.profile.children,
            selected: selected,
            scheduleController: _scheduleController,
            onSelectChild: _selectChild,
          ),
          ParentProfileScreen(
            profile: widget.profile,
            user: widget.user,
            onLogout: widget.onLogout,
            profileApi: widget.profileApi,
            preferences: widget.preferences,
          ),
        ],
      ),
      bottomNavigationBar: ParentBottomNav(
        selected: _tab,
        onSelect: (tab) => setState(() => _tab = tab),
      ),
    );
  }
}

class _CalendarTab extends StatelessWidget {
  const _CalendarTab({
    required this.children,
    required this.selected,
    required this.scheduleController,
    required this.onSelectChild,
  });

  final List<ParentChild> children;
  final ParentChild? selected;
  final ScheduleController scheduleController;
  final ValueChanged<ParentChild> onSelectChild;

  @override
  Widget build(BuildContext context) {
    if (selected == null) {
      return const AubEmptyState(message: AppStrings.noChildren);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AubSpacing.margin,
            AubSpacing.xs,
            AubSpacing.margin,
            AubSpacing.sm,
          ),
          child: Column(
            children: [
              ChildSwitcher(
                children: children,
                selected: selected,
                onSelect: onSelectChild,
              ),
              const SizedBox(height: AubSpacing.sm),
              ChildContextHeader(
                child: selected!,
                caption: AppStrings.calendarTab,
              ),
            ],
          ),
        ),
        Expanded(
          child: ScheduleScreen(
            controller: scheduleController,
            childName: selected!.displayName,
            embedded: true,
            studentVisuals: true,
          ),
        ),
      ],
    );
  }
}
