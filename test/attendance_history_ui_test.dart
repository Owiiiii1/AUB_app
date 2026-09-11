import 'package:aub/app/app_strings.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/presentation/attendance_history_screen.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/auth_session.dart';
import 'package:aub/features/home/presentation/parent_home_screen.dart';
import 'package:aub/features/home/presentation/student_home_screen.dart';
import 'package:aub/features/home/presentation/student_shell.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/auth_fixtures.dart';
import 'helpers/fake_attendance_api.dart';
import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  testWidgets('student home has Orario and Presenze', (tester) async {
    final me = MePayload.fromJson(studentMeJson(photoUrl: null));
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
      MaterialApp(
        home: StudentShell(
          profile: me.profile as StudentProfile,
          user: me.user,
          onLogout: () {},
          scheduleRepository: ScheduleRepository(api: scheduleApi),
          attendanceHistoryRepository: AttendanceHistoryRepository(
            api: attendanceApi,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.text(AppStrings.schedule), findsWidgets);
    expect(find.text(AppStrings.attendance), findsWidgets);
    await tester.tap(find.byKey(const Key('student-nav-attendance')));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.attendanceRegister.toUpperCase()), findsOneWidget);
  });

  testWidgets('parent child has Orario and Presenze', (tester) async {
    ParentChild? attendanceChild;
    await tester.pumpWidget(
      MaterialApp(
        home: ParentHomeScreen(
          profile: ParentProfile.fromJson(
            parentMeJson()['profile'] as Map<String, dynamic>,
          ),
          onLogout: () {},
          onOpenChildAttendance: (child) => attendanceChild = child,
        ),
      ),
    );

    expect(find.text(AppStrings.schedule), findsOneWidget);
    expect(find.text(AppStrings.attendance), findsOneWidget);
    await tester.tap(find.text(AppStrings.attendance));
    await tester.pump();
    expect(attendanceChild?.displayName, 'Giulia Verdi');
  });

  testWidgets('history shows title summary records and statuses', (tester) async {
    final api = FakeAttendanceApi()..history = attendanceHistory();
    final controller = AttendanceHistoryController(
      repository: AttendanceHistoryRepository(api: api),
    );

    await tester.pumpWidget(
      MaterialApp(home: AttendanceHistoryScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.attendance), findsOneWidget);
    expect(find.text('Settembre 2026'), findsOneWidget);
    expect(find.text(AppStrings.thisMonth), findsOneWidget);
    expect(find.text(AppStrings.totalLabel), findsOneWidget);
    expect(find.text(AppStrings.presentPlural), findsOneWidget);
    expect(find.text(AppStrings.absentPlural), findsOneWidget);
    expect(find.text(AppStrings.excusedPlural), findsOneWidget);
    expect(find.text('Danza classica'), findsWidgets);
    expect(find.text(AppStrings.present), findsOneWidget);
    expect(find.text(AppStrings.absent), findsOneWidget);
    await tester.scrollUntilVisible(find.text(AppStrings.excused), 200);
    expect(find.text(AppStrings.excused), findsOneWidget);
    expect(find.textContaining('Maria Rossi'), findsWidgets);
    expect(find.textContaining('Sala 2'), findsWidgets);
  });

  testWidgets('parent history title uses child name', (tester) async {
    final api = FakeAttendanceApi()..history = attendanceHistory();
    final controller = AttendanceHistoryController(
      repository: AttendanceHistoryRepository(api: api),
      studentId: 8,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AttendanceHistoryScreen(
          controller: controller,
          childName: 'Sofia',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.attendanceOf('Sofia')), findsOneWidget);
  });

  testWidgets('empty month shows empty copy', (tester) async {
    final api = FakeAttendanceApi()
      ..history = attendanceHistory(
        marked: 0,
        present: 0,
        absent: 0,
        excused: 0,
        records: const [],
      );
    final controller = AttendanceHistoryController(
      repository: AttendanceHistoryRepository(api: api),
    );

    await tester.pumpWidget(
      MaterialApp(home: AttendanceHistoryScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.noAttendanceThisMonth), findsOneWidget);
    expect(find.text('Nessuna assenza'), findsNothing);
  });

  testWidgets('previous and next month buttons request adjacent months', (
    tester,
  ) async {
    final api = FakeAttendanceApi()..history = attendanceHistory();
    final controller = AttendanceHistoryController(
      repository: AttendanceHistoryRepository(api: api),
    );

    await tester.pumpWidget(
      MaterialApp(home: AttendanceHistoryScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    api.history = attendanceHistory(month: '2026-08');
    await tester.tap(find.byIcon(Icons.chevron_left));
    await tester.pumpAndSettle();
    expect(api.lastHistoryMonth, '2026-08');
    expect(find.text('Agosto 2026'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.text('Settembre 2026'), findsOneWidget);
  });
}
