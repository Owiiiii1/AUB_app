import 'package:aub/app/app_config.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/presentation/attendance_screen.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/home/presentation/teacher_home_screen.dart';
import 'package:aub/features/home/presentation/teacher_presenze_screen.dart';
import 'package:aub/features/home/presentation/teacher_shell.dart';
import 'package:aub/features/home/state/teacher_home_controller.dart';
import 'package:aub/features/profile/presentation/teacher_profile_screen.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
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

MePayload _teacherMe() => MePayload.fromJson(teacherMeJson());

Map<String, dynamic> _lessonJson({
  required int id,
  required String title,
  required String status,
  String startsAt = '16:00',
  String endsAt = '17:30',
  String className = 'Classe A',
}) {
  return {
    'id': id,
    'starts_at': startsAt,
    'ends_at': endsAt,
    'title': title,
    'lesson': {'id': id, 'name': title},
    'academy_class': {'id': 3, 'name': className},
    'location': {
      'building': {'id': 1, 'name': 'Sede centrale'},
      'room': {'id': 4, 'name': 'Sala 2'},
    },
    'status': status,
  };
}

Widget _shell({
  required FakeScheduleApi scheduleApi,
  required FakeAttendanceApi attendanceApi,
  VoidCallback? onLogout,
  TeacherHomeController? homeController,
  ScheduleController? scheduleController,
}) {
  final payload = _teacherMe();
  return MaterialApp(
    home: TeacherShell(
      profile: payload.profile as TeacherProfile,
      user: payload.user,
      onLogout: onLogout ?? () {},
      scheduleRepository: ScheduleRepository(api: scheduleApi),
      attendanceRepository: AttendanceRepository(api: attendanceApi),
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

  Future<void> pumpTeacher(WidgetTester tester, Widget app) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(app);
  }

  testWidgets('oggi is selected initially and tabs switch', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: true));
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TeacherHomeScreen), findsOneWidget);
    expect(find.byKey(const Key('teacher-nav-today')), findsOneWidget);

    await tester.tap(find.byKey(const Key('teacher-nav-schedule')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.schedule), findsWidgets);

    await tester.tap(find.byKey(const Key('teacher-nav-attendance')));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherPresenzeScreen), findsOneWidget);

    await tester.tap(find.byKey(const Key('teacher-nav-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(TeacherProfileScreen), findsOneWidget);
  });

  testWidgets('today shows teacher name next lesson and today lessons', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherScheduleJson());
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Elena'), findsWidgets);
    expect(find.text(AppStrings.teacherRole), findsWidgets);
    expect(find.text('Danza classica'), findsWidgets);
    expect(find.text('Classe A'), findsWidgets);
    expect(find.textContaining('Sala 2'), findsWidgets);
    expect(find.text(AppStrings.openAttendance), findsWidgets);
  });

  testWidgets('today shows moved and cancelled without using cancelled as next', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(
        teacherScheduleJson(
          extraLessons: [
            _lessonJson(
              id: 102,
              title: 'Repertorio',
              status: 'moved',
              startsAt: '18:00',
              endsAt: '19:00',
            ),
            _lessonJson(
              id: 103,
              title: 'Contemporaneo',
              status: 'cancelled',
              startsAt: '11:00',
              endsAt: '12:00',
            ),
          ],
        ),
      );
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.text('Danza classica'), findsWidgets);
    expect(find.text('Repertorio'), findsWidgets);
    expect(find.text('Contemporaneo'), findsWidgets);
    expect(find.text(AppStrings.moved.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.cancelled.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.openAttendance), findsWidgets);
  });

  testWidgets('today empty day does not use stitch demo names', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: true));
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noLessonToday), findsOneWidget);
    expect(find.text(AppStrings.noUpcomingLesson), findsOneWidget);
    expect(find.text('Classe A'), findsNothing);
    expect(find.text('Danza classica'), findsNothing);
    expect(find.text('Sala 2'), findsNothing);
    expect(find.text('Maria Rossi'), findsNothing);
  });

  testWidgets('orario shows own lessons class week nav moved and cancelled', (
    tester,
  ) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(
        teacherScheduleJson(
          extraLessons: [
            _lessonJson(
              id: 102,
              title: 'Repertorio',
              status: 'moved',
              startsAt: '18:00',
              endsAt: '19:00',
            ),
            _lessonJson(
              id: 103,
              title: 'Contemporaneo',
              status: 'cancelled',
              startsAt: '11:00',
              endsAt: '12:00',
            ),
          ],
        ),
      );
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('teacher-nav-schedule')));
    await tester.pumpAndSettle();

    expect(find.text('DANZA CLASSICA'), findsWidgets);
    expect(find.text('Classe A'), findsWidgets);
    expect(find.text(AppStrings.thisWeek), findsOneWidget);
    expect(find.text(AppStrings.moved.toUpperCase()), findsWidgets);
    expect(find.text(AppStrings.cancelled.toUpperCase()), findsWidgets);
  });

  testWidgets('orario empty week', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: true));
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('teacher-nav-schedule')));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noLessonsThisWeek), findsOneWidget);
  });

  testWidgets('presenze list shows lessons and opens roster', (tester) async {
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherScheduleJson());
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(scheduleApi: scheduleApi, attendanceApi: attendanceApi),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('teacher-nav-attendance')));
    await tester.pumpAndSettle();

    expect(find.text('Danza classica'), findsWidgets);
    expect(find.text('Classe A'), findsWidgets);

    await tester.tap(find.text(AppStrings.openAttendance).first);
    await tester.pumpAndSettle();

    expect(find.byType(AttendanceScreen), findsOneWidget);
    expect(find.text('Anna Rossi'), findsOneWidget);
    expect(find.text('Bruno Neri'), findsOneWidget);
  });

  testWidgets('roster unmarked present absent excused mark all and save', (
    tester,
  ) async {
    final api = FakeAttendanceApi()..roster = attendanceRoster();
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await pumpTeacher(
      tester,
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Anna Rossi'), findsOneWidget);
    expect(find.text('Bruno Neri'), findsOneWidget);
    expect(find.text(AppStrings.unmarked), findsOneWidget);
    expect(find.text(AppStrings.present), findsWidgets);
    expect(find.text(AppStrings.absent), findsWidgets);
    expect(find.text(AppStrings.excused), findsWidgets);

    final saveFinder = find.widgetWithText(
      FilledButton,
      AppStrings.saveAttendance,
    );
    expect(tester.widget<FilledButton>(saveFinder).onPressed, isNull);

    await tester.tap(find.text(AppStrings.absent).first);
    await tester.pump();
    expect(tester.widget<FilledButton>(saveFinder).onPressed, isNotNull);

    await tester.tap(find.text(AppStrings.excused).first);
    await tester.pump();

    await tester.tap(find.text(AppStrings.markAllPresent));
    await tester.pump();
    expect(controller.canSave, isTrue);
    expect(
      controller.state.roster!.students.every(
        (student) => controller.statusOf(student) == AttendanceStatus.present,
      ),
      isTrue,
    );

    await tester.tap(saveFinder);
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.attendanceSaved), findsOneWidget);
  });

  testWidgets('cancelled roster is read-only', (tester) async {
    final api = FakeAttendanceApi()
      ..roster = attendanceRoster(
        editable: false,
        reason: 'cancelled',
        status: 'cancelled',
      );
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await pumpTeacher(
      tester,
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lessonCancelled), findsOneWidget);
    expect(find.text(AppStrings.saveAttendance), findsNothing);
    expect(find.text(AppStrings.markAllPresent), findsNothing);
  });

  testWidgets('save network failure keeps draft', (tester) async {
    final api = FakeAttendanceApi()
      ..roster = attendanceRoster()
      ..throwOnSave = const ApiException(
        code: ApiErrorCode.network,
        message: 'offline',
      );
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await pumpTeacher(
      tester,
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.absent).first);
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, AppStrings.saveAttendance));
    await tester.pumpAndSettle();

    expect(controller.isDirty, isTrue);
    expect(
      controller.statusOf(controller.state.roster!.students[0]),
      AttendanceStatus.absent,
    );
    expect(find.text(AppStrings.noConnection), findsOneWidget);
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, AppStrings.saveAttendance),
          )
          .onPressed,
      isNotNull,
    );
  });

  testWidgets('unsaved back shows confirmation', (tester) async {
    final api = FakeAttendanceApi()..roster = attendanceRoster();
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await pumpTeacher(
      tester,
      MaterialApp(
        home: Builder(
          builder: (context) {
            return TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AttendanceScreen(controller: controller),
                  ),
                );
              },
              child: const Text('open'),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.absent).first);
    await tester.pump();
    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.unsavedAttendance), findsOneWidget);
    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceScreen), findsOneWidget);
  });

  testWidgets('profile shows real teacher data and logout', (tester) async {
    var loggedOut = false;
    final scheduleApi = FakeScheduleApi()
      ..responses['current'] =
          ScheduleWeekView.fromJson(teacherEmptyScheduleJson(published: true));
    final attendanceApi = FakeAttendanceApi()..roster = attendanceRoster();

    await pumpTeacher(
      tester,
      _shell(
        scheduleApi: scheduleApi,
        attendanceApi: attendanceApi,
        onLogout: () => loggedOut = true,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('teacher-nav-profile')));
    await tester.pumpAndSettle();

    expect(find.text('Elena Bianchi'), findsWidgets);
    expect(find.text('teacher@example.test'), findsOneWidget);
    expect(find.text(AppStrings.teacherRole), findsWidgets);

    await tester.scrollUntilVisible(find.text(AppStrings.logoutAccount), 300);
    await tester.tap(find.text(AppStrings.logoutAccount));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.logoutConfirmAction));
    await tester.pumpAndSettle();
    expect(loggedOut, isTrue);
  });
}
