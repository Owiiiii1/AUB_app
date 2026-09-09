import 'package:aub/app/app_strings.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/presentation/schedule_screen.dart';
import 'package:aub/features/schedule/presentation/widgets/schedule_widgets.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('it');
  });

  testWidgets('student schedule renders lesson details', (tester) async {
    final api = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(publishedScheduleJson());
    final controller = ScheduleController(repository: ScheduleRepository(api: api));

    await tester.pumpWidget(
      MaterialApp(home: ScheduleScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orario'), findsOneWidget);
    expect(find.text('Danza classica'), findsOneWidget);
    expect(find.text('Sala 2'), findsOneWidget);
    expect(find.text('Maria Rossi'), findsOneWidget);
    expect(find.textContaining('16:00'), findsOneWidget);
  });

  testWidgets('parent child name renders in the header', (tester) async {
    final api = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(publishedScheduleJson());
    final controller = ScheduleController(
      repository: ScheduleRepository(api: api),
      studentId: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ScheduleScreen(controller: controller, childName: 'Sofia'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.scheduleOf('Sofia')), findsOneWidget);
  });

  testWidgets('unpublished week shows empty state', (tester) async {
    final api = FakeScheduleApi()
      ..responses['current'] = ScheduleWeekView.fromJson(unpublishedScheduleJson());
    final controller = ScheduleController(repository: ScheduleRepository(api: api));

    await tester.pumpWidget(
      MaterialApp(home: ScheduleScreen(controller: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.unpublishedWeek), findsOneWidget);
  });

  testWidgets('cancelled and moved badges render', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              ScheduleLessonTile(
                lesson: ScheduleLesson(
                  id: 1,
                  startsAt: '16:00',
                  endsAt: '17:00',
                  title: 'Danza',
                  status: ScheduleLessonStatus.cancelled,
                ),
              ),
              ScheduleLessonTile(
                lesson: ScheduleLesson(
                  id: 2,
                  startsAt: '18:00',
                  endsAt: '19:00',
                  title: 'Repertorio',
                  status: ScheduleLessonStatus.moved,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Annullata'), findsOneWidget);
    expect(find.text('Spostata'), findsOneWidget);
  });
}
