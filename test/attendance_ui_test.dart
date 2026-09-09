import 'package:aub/app/app_strings.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/presentation/attendance_screen.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/presentation/widgets/schedule_widgets.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/fake_attendance_api.dart';
import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  testWidgets('roster displays existing status and save button', (tester) async {
    final api = FakeAttendanceApi()..roster = attendanceRoster();
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await tester.pumpWidget(
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Danza classica'), findsWidgets);
    expect(find.text('Classe A'), findsOneWidget);
    expect(find.textContaining('16:00'), findsOneWidget);
    expect(find.text('Sala 2'), findsOneWidget);
    expect(find.text('Anna Rossi'), findsOneWidget);
    expect(find.text('Bruno Neri'), findsOneWidget);
    expect(find.text(AppStrings.present), findsWidgets);
    expect(find.text(AppStrings.saveAttendance), findsOneWidget);

    final saveButton = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, AppStrings.saveAttendance),
    );
    expect(saveButton.onPressed, isNull);

    await tester.tap(find.text(AppStrings.absent).first);
    await tester.pump();
    expect(
      tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, AppStrings.saveAttendance),
      ).onPressed,
      isNotNull,
    );
  });

  testWidgets('mark all present enables save', (tester) async {
    final api = FakeAttendanceApi()..roster = attendanceRoster();
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await tester.pumpWidget(
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.markAllPresent));
    await tester.pump();
    expect(controller.canSave, isTrue);
    expect(
      controller.state.roster!.students.every(
        (student) => controller.statusOf(student) == AttendanceStatus.present,
      ),
      isTrue,
    );
  });

  testWidgets('cancelled lesson is read-only without save', (tester) async {
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

    await tester.pumpWidget(
      MaterialApp(home: AttendanceScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lessonCancelled), findsOneWidget);
    expect(find.text(AppStrings.saveAttendance), findsNothing);
    expect(find.text(AppStrings.markAllPresent), findsNothing);
  });

  testWidgets('dirty back shows confirmation', (tester) async {
    final api = FakeAttendanceApi()..roster = attendanceRoster();
    final controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );

    await tester.pumpWidget(
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
    expect(find.byType(AttendanceScreen), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();
    expect(find.byType(AttendanceScreen), findsOneWidget);
  });

  testWidgets('teacher lesson card is tappable with chevron', (tester) async {
    final api = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(teacherScheduleJson());
    final controller = ScheduleController(
      repository: ScheduleRepository(api: api),
      kind: ScheduleKind.teacher,
    );
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleScreen(
          controller: controller,
          onLessonTap: (_) => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsWidgets);
    await tester.tap(find.text('Danza classica'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  testWidgets('student lesson card has no attendance chevron', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ScheduleLessonTile(
            lesson: ScheduleLesson(
              id: 1,
              startsAt: '16:00',
              endsAt: '17:00',
              title: 'Danza',
              status: ScheduleLessonStatus.published,
            ),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.chevron_right), findsNothing);
  });
}
