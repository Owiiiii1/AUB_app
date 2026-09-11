import 'package:aub/app/app_strings.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_history_screen.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/home/presentation/student_home_screen.dart';
import 'package:aub/features/home/presentation/student_shell.dart';
import 'package:aub/features/home/state/student_home_controller.dart';
import 'package:aub/features/profile/presentation/student_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/auth_fixtures.dart';
import 'helpers/fake_attendance_api.dart';
import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

MePayload _studentMe() => MePayload.fromJson(studentMeJson(photoUrl: null));

Widget _shell({
  required FakeScheduleApi scheduleApi,
  required FakeAttendanceApi attendanceApi,
  VoidCallback? onLogout,
  StudentHomeController? homeController,
}) {
  final me = _studentMe();
  return MaterialApp(
    home: StudentShell(
      profile: me.profile as StudentProfile,
      user: me.user,
      onLogout: onLogout ?? () {},
      scheduleRepository: ScheduleRepository(api: scheduleApi),
      attendanceHistoryRepository: AttendanceHistoryRepository(api: attendanceApi),
      homeController: homeController,
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  testWidgets('home is selected initially and tabs switch', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(unpublishedScheduleJson());
    final attendanceApi = FakeAttendanceApi()
      ..history = attendanceHistory(
        marked: 0,
        present: 0,
        absent: 0,
        excused: 0,
        records: const [],
      );

    await tester.pumpWidget(
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    await tester.tap(find.byKey(const Key('student-nav-schedule')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.weeklySchedule.toUpperCase()), findsOneWidget);

    await tester.tap(find.byKey(const Key('student-nav-attendance')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.attendanceRegister.toUpperCase()), findsOneWidget);

    await tester.tap(find.byKey(const Key('student-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(StudentProfileScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('student-nav-home')));
    await tester.pumpAndSettle();
    expect(find.text('CIAO, MARIO'), findsOneWidget);
  });

  testWidgets('home shows real name next lesson today and summary', (
    tester,
  ) async {
    final now = DateTime(2026, 9, 7, 15, 0);
    final json = publishedScheduleJson();
    (json['days'] as List)[0]['lessons'].add({
      'id': 101,
      'starts_at': '18:15',
      'ends_at': '19:45',
      'title': 'Repertorio',
      'lesson': {'id': 5, 'name': 'Repertorio'},
      'teacher': {'id': 8, 'display_name': 'Maria Rossi'},
      'location': {
        'building': {'id': 1, 'name': 'SEDE ACCADEMIA'},
        'room': {'id': 4, 'name': 'Sala 2'},
      },
      'status': 'published',
    });
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(json);
    final attendanceApi = FakeAttendanceApi()..history = attendanceHistory();
    final homeController = StudentHomeController(
      scheduleRepository: ScheduleRepository(api: scheduleApi),
      attendanceHistoryRepository: AttendanceHistoryRepository(
        api: attendanceApi,
      ),
      clock: AcademyClock(now: () => now),
    );

    await tester.pumpWidget(
      _shell(
        scheduleApi: scheduleApi,
        attendanceApi: attendanceApi,
        homeController: homeController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CIAO, MARIO'), findsOneWidget);
    expect(find.text(AppStrings.nextLesson.toUpperCase()), findsWidgets);
    expect(find.text('Danza classica'), findsWidgets);
    await tester.scrollUntilVisible(find.text('Repertorio'), 300);
    expect(find.text('Repertorio'), findsOneWidget);
    expect(find.text(AppStrings.presentPlural.toUpperCase()), findsWidgets);
  });

  testWidgets('home empty states when no schedule or attendance', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(unpublishedScheduleJson());
    final attendanceApi = FakeAttendanceApi()
      ..history = attendanceHistory(
        marked: 0,
        present: 0,
        absent: 0,
        excused: 0,
        records: const [],
      );

    await tester.pumpWidget(
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noUpcomingLesson), findsOneWidget);
    expect(find.text(AppStrings.noLessonToday), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(AppStrings.noAttendanceThisMonth),
      400,
    );
    expect(find.text(AppStrings.noAttendanceThisMonth), findsWidgets);
    expect(find.text('0/0'), findsNothing);
    expect(find.text('Nessuna assenza'), findsNothing);
  });

  testWidgets('student schedule shows published moved cancelled and empty', (
    tester,
  ) async {
    final json = publishedScheduleJson();
    (json['days'] as List)[1]['lessons'] = [
      {
        'id': 200,
        'starts_at': '17:45',
        'ends_at': '19:15',
        'title': 'Repertorio',
        'teacher': {'id': 9, 'display_name': 'K. Shaidullin'},
        'location': {
          'building': {'id': 1, 'name': 'Sede'},
          'room': {'id': 5, 'name': 'Sala Taglioni'},
        },
        'status': 'moved',
      },
      {
        'id': 201,
        'starts_at': '17:15',
        'ends_at': '18:45',
        'title': 'Pilates',
        'teacher': {'id': 10, 'display_name': 'Valeria Rossi'},
        'location': {
          'building': {'id': 1, 'name': 'Sede'},
          'room': {'id': 6, 'name': 'Sala Petipa'},
        },
        'status': 'cancelled',
      },
    ];
    final api = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(json);
    final controller = ScheduleController(
      repository: ScheduleRepository(api: api),
      kind: ScheduleKind.student,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleScreen(
          controller: controller,
          studentVisuals: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Danza classica'.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.confirmed.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.moved.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.cancelled.toUpperCase()), findsOneWidget);
    expect(
      find.text(AppStrings.emptyDaySchedule, skipOffstage: false),
      findsWidgets,
    );
  });

  testWidgets('student attendance shows three statuses and empty copy', (
    tester,
  ) async {
    final api = FakeAttendanceApi()..history = attendanceHistory();
    final controller = AttendanceHistoryController(
      repository: AttendanceHistoryRepository(api: api),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AttendanceHistoryScreen(
          controller: controller,
          studentVisuals: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.attendanceRegister.toUpperCase()), findsOneWidget);
    expect(find.text(AppStrings.thisMonth), findsOneWidget);
    expect(find.text(AppStrings.present.toUpperCase()), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(AppStrings.absent.toUpperCase()),
      400,
    );
    expect(find.text(AppStrings.absent.toUpperCase()), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text(AppStrings.excused.toUpperCase()),
      400,
    );
    expect(find.text(AppStrings.excused.toUpperCase()), findsOneWidget);
  });

  testWidgets('profile shows user data and logout', (tester) async {
    var loggedOut = false;
    final me = _studentMe();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StudentProfileScreen(
            profile: me.profile as StudentProfile,
            user: me.user,
            onLogout: () => loggedOut = true,
          ),
        ),
      ),
    );

    expect(find.text('Mario Rossi'), findsOneWidget);
    expect(find.text('mario@example.test'), findsOneWidget);
    expect(find.text(AppStrings.logoutAccount), findsOneWidget);
    await tester.tap(find.text(AppStrings.logoutAccount));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.logoutConfirmAction));
    await tester.pumpAndSettle();
    expect(loggedOut, isTrue);
  });
}

