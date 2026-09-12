import 'package:aub/app/app_config.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_history_screen.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/home/presentation/parent_children_screen.dart';
import 'package:aub/features/home/presentation/parent_home_screen.dart';
import 'package:aub/features/home/presentation/parent_shell.dart';
import 'package:aub/features/home/state/parent_home_controller.dart';
import 'package:aub/features/profile/presentation/parent_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/auth_fixtures.dart';
import 'helpers/fake_attendance_api.dart';
import 'helpers/fake_profile_api.dart';
import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

final _testNow = DateTime(2026, 9, 7, 10);

MePayload _parentMe({List<Map<String, dynamic>>? children}) {
  return MePayload.fromJson(parentMeJson(children: children));
}

List<Map<String, dynamic>> _twoChildren() {
  return [
    {
      'id': 1,
      'first_name': 'Giulia',
      'last_name': 'Verdi',
      'display_name': 'Giulia Verdi',
      'academy_class': {'id': 3, 'name': 'Own Class'},
    },
    {
      'id': 2,
      'first_name': 'Luca',
      'last_name': 'Verdi',
      'display_name': 'Luca Verdi',
      'academy_class': {'id': 4, 'name': 'Classe B'},
    },
  ];
}

Widget _shell({
  required FakeScheduleApi scheduleApi,
  required FakeAttendanceApi attendanceApi,
  MePayload? me,
  VoidCallback? onLogout,
  ParentHomeController? homeController,
  ScheduleController? scheduleController,
}) {
  final payload = me ?? _parentMe();
  return MaterialApp(
    home: ParentShell(
      profile: payload.profile as ParentProfile,
      user: payload.user,
      onLogout: onLogout ?? () {},
      scheduleRepository: ScheduleRepository(api: scheduleApi),
      attendanceHistoryRepository: AttendanceHistoryRepository(
        api: attendanceApi,
      ),
      homeController: homeController,
      scheduleController: scheduleController,
      profileApi: FakeProfileApi(
        ApiClient(config: AppConfig(apiBaseUrl: testApiBaseUrl)),
      ),
      clock: AcademyClock(now: () => _testNow),
    ),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  Future<void> pumpParent(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
  }

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

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ParentHomeScreen), findsOneWidget);
    expect(find.byKey(const Key('parent-nav-home')), findsOneWidget);

    await tester.tap(find.byKey(const Key('parent-nav-children')));
    await tester.pumpAndSettle();
    expect(find.byType(ParentChildrenScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('parent-nav-calendar')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.calendarTab), findsWidgets);

    await tester.tap(find.byKey(const Key('parent-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ParentProfileScreen), findsOneWidget);
  });

  testWidgets('home shows parent name child cards next lesson and attendance', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(publishedScheduleJson());
    final attendanceApi = FakeAttendanceApi()
      ..history = attendanceHistory();

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Maria'), findsWidgets);
    expect(find.text('Giulia Verdi'), findsWidgets);
    expect(find.textContaining('Own Class'), findsWidgets);
    expect(find.text('Danza classica'), findsWidgets);
    expect(find.textContaining(AppStrings.presentPlural), findsWidgets);
  });

  testWidgets('home empty data does not use stitch demo names', (tester) async {
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

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sofia Rossi'), findsNothing);
    expect(find.text('Classe A'), findsNothing);
    expect(find.text(AppStrings.noUpcomingLesson), findsWidgets);
    expect(find.text(AppStrings.noAttendanceThisMonth), findsWidgets);
  });

  testWidgets('one child and no children', (tester) async {
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

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('parent-child-card-1')), findsOneWidget);
    expect(find.byKey(const Key('parent-change-child')), findsNothing);

        await pumpParent(tester,
      _shell(
        scheduleApi: scheduleApi,
        attendanceApi: attendanceApi,
        me: _parentMe(children: const []),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noChildren), findsWidgets);
    expect(find.byKey(const Key('parent-child-card-1')), findsNothing);
  });

  testWidgets('child switching isolates sibling schedule and attendance', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..childResponses[1] =
          ScheduleWeekView.fromJson(publishedScheduleJson())
      ..childResponses[2] = ScheduleWeekView.fromJson(
        publishedScheduleJson(title: 'Hip hop'),
      );
    final attendanceApi = FakeAttendanceApi()
      ..childHistories[1] = attendanceHistory(
        present: 2,
        absent: 0,
        excused: 0,
        marked: 2,
        records: [
          attendanceHistoryJson()['records'][0] as Map<String, dynamic>,
        ],
      )
      ..childHistories[2] = attendanceHistory(
        present: 0,
        absent: 1,
        excused: 0,
        marked: 1,
        records: [
          {
            'id': 90,
            'date': '2026-09-09',
            'starts_at': '15:00',
            'ends_at': '16:00',
            'status': 'absent',
            'lesson': {'id': 9, 'name': 'Hip hop'},
            'title': 'Hip hop',
            'teacher': {'id': 7, 'display_name': 'Elena Bianchi'},
            'location': {
              'building': {'id': 1, 'name': 'Sede centrale'},
              'room': {'id': 2, 'name': 'Sala 3'},
            },
          },
        ],
      );
    final scheduleController = ScheduleController(
      repository: ScheduleRepository(api: scheduleApi),
      kind: ScheduleKind.child,
      studentId: 1,
      clock: AcademyClock(now: () => _testNow),
    );

        await pumpParent(tester,
      _shell(
        scheduleApi: scheduleApi,
        attendanceApi: attendanceApi,
        me: _parentMe(children: _twoChildren()),
        scheduleController: scheduleController,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Giulia Verdi'), findsWidgets);
    expect(find.text('Luca Verdi'), findsWidgets);

    await tester.tap(find.byKey(const Key('parent-nav-calendar')));
    await tester.pumpAndSettle();
    expect(scheduleController.studentId, 1);
    expect(
      scheduleController.state.view?.days.first.lessons.single.title,
      'Danza classica',
    );

    await tester.tap(find.byKey(const Key('parent-nav-children')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-change-child')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-select-child-2')));
    await tester.pumpAndSettle();

    expect(find.textContaining('Luca Verdi'), findsWidgets);
    expect(scheduleController.studentId, 2);
    expect(
      scheduleController.state.view?.days.first.lessons.single.title,
      'Hip hop',
    );

    await tester.tap(find.byKey(const Key('parent-nav-calendar')));
    await tester.pumpAndSettle();
    expect(scheduleController.lastRequestedStudentId, 2);
    expect(find.text('HIP HOP'), findsWidgets);

    await tester.tap(find.byKey(const Key('parent-nav-home')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('parent-child-presenze-2')),
      400,
      scrollable: find.descendant(
        of: find.byType(ParentHomeScreen),
        matching: find.byType(Scrollable),
      ),
    );
    await tester.tap(find.byKey(const Key('parent-child-presenze-2')));
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceHistoryScreen), findsOneWidget);
    expect(find.text(AppStrings.attendanceOf('Luca Verdi')), findsOneWidget);
    expect(find.text(AppStrings.absent.toUpperCase()), findsWidgets);
  });

  testWidgets('orario shows published moved cancelled and empty', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(
        publishedScheduleJson(
          extraLessons: [
            {
              'id': 102,
              'starts_at': '18:00',
              'ends_at': '19:00',
              'title': 'Repertorio',
              'lesson': {'id': 5, 'name': 'Repertorio'},
              'teacher': {'id': 8, 'display_name': 'Maria Rossi'},
              'location': {
                'building': {'id': 1, 'name': 'SEDE ACCADEMIA'},
                'room': {'id': 4, 'name': 'Sala 2'},
              },
              'status': 'moved',
            },
            {
              'id': 103,
              'starts_at': '19:15',
              'ends_at': '20:00',
              'title': 'Contemporaneo',
              'lesson': {'id': 6, 'name': 'Contemporaneo'},
              'teacher': {'id': 8, 'display_name': 'Maria Rossi'},
              'location': {
                'building': {'id': 1, 'name': 'SEDE ACCADEMIA'},
                'room': {'id': 4, 'name': 'Sala 2'},
              },
              'status': 'cancelled',
            },
          ],
        ),
      );
    final attendanceApi = FakeAttendanceApi()
      ..history = attendanceHistory(
        marked: 0,
        present: 0,
        absent: 0,
        excused: 0,
        records: const [],
      );

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-nav-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Giulia Verdi'), findsWidgets);
    expect(find.text('DANZA CLASSICA'), findsWidgets);
    expect(find.text('REPERTORIO'), findsWidgets);
    expect(find.text('CONTEMPORANEO'), findsWidgets);
    expect(find.text(AppStrings.moved.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.cancelled.toUpperCase()), findsWidgets);
  });

  testWidgets('orario empty unpublished week', (tester) async {
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

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-nav-calendar')));
    await tester.pumpAndSettle();
    expect(find.text('Giulia Verdi'), findsWidgets);
    expect(find.text(AppStrings.unpublishedWeek), findsOneWidget);
  });

  testWidgets('presenze shows statuses and empty month', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(unpublishedScheduleJson());
    final attendanceApi = FakeAttendanceApi()..history = attendanceHistory();

        await pumpParent(tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-child-presenze-1')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.attendanceOf('Giulia Verdi')), findsOneWidget);
    expect(find.text(AppStrings.present.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.absent.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.excused.toUpperCase()), findsWidgets);

    await tester.pageBack();
    await tester.pumpAndSettle();

    attendanceApi.history = attendanceHistory(
      marked: 0,
      present: 0,
      absent: 0,
      excused: 0,
      records: const [],
    );
    final emptyMe = _parentMe();
        await pumpParent(tester,
      MaterialApp(
        home: ParentShell(
          profile: emptyMe.profile as ParentProfile,
          user: emptyMe.user,
          onLogout: () {},
          scheduleRepository: ScheduleRepository(api: scheduleApi),
          attendanceHistoryRepository: AttendanceHistoryRepository(
            api: attendanceApi,
          ),
          clock: AcademyClock(now: () => _testNow),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-child-presenze-1')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.noAttendanceThisMonth), findsOneWidget);
  });

  testWidgets('profile shows real user data and logout', (tester) async {
    var loggedOut = false;
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

        await pumpParent(tester,
      _shell(
        scheduleApi: scheduleApi,
        attendanceApi: attendanceApi,
        onLogout: () => loggedOut = true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('parent-nav-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Maria Verdi'), findsWidgets);
    expect(find.text('parent@example.test'), findsOneWidget);
    expect(find.text('Giulia Verdi'), findsWidgets);

    await tester.scrollUntilVisible(
      find.text(AppStrings.logoutAccount),
      300,
    );
    await tester.tap(find.text(AppStrings.logoutAccount));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.logoutConfirmAction));
    await tester.pumpAndSettle();
    expect(loggedOut, isTrue);
  });
}
