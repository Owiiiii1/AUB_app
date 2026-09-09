import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'package:aub/features/schedule/models/schedule_week.dart';
import 'package:aub/features/schedule/state/schedule_controller.dart';
import 'package:aub/features/schedule/schedule_kind.dart';
import 'package:aub/features/schedule/state/schedule_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/fake_schedule_api.dart';
import 'helpers/schedule_fixtures.dart';

void main() {
  late FakeScheduleApi api;
  late ScheduleRepository repository;

  setUp(() {
    api = FakeScheduleApi();
    repository = ScheduleRepository(api: api);
    api.responses['current'] = ScheduleWeekView.fromJson(publishedScheduleJson());
  });

  test('current week loads', () async {
    final controller = ScheduleController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.loaded);
    expect(controller.state.view?.days.first.lessons.single.title, 'Danza classica');
    expect(api.studentLoads, 1);
  });

  test('previous and next week request shifted dates', () async {
    api.responses['2026-08-31'] = ScheduleWeekView.fromJson({
      ...publishedScheduleJson(),
      'week': {
        'starts_on': '2026-08-31',
        'ends_on': '2026-09-06',
        'published': true,
      },
    });
    api.responses['2026-09-14'] = ScheduleWeekView.fromJson({
      ...publishedScheduleJson(),
      'week': {
        'starts_on': '2026-09-14',
        'ends_on': '2026-09-20',
        'published': true,
      },
    });

    final controller = ScheduleController(repository: repository);
    await controller.loadCurrent();
    await controller.loadPrevious();
    expect(api.lastWeek, DateTime(2026, 8, 31));

    await controller.loadCurrent();
    await controller.loadNext();
    expect(api.lastWeek, DateTime(2026, 9, 14));
  });

  test('unpublished week is a dedicated state', () async {
    api.responses['current'] = ScheduleWeekView.fromJson(unpublishedScheduleJson());
    final controller = ScheduleController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.unpublished);
    expect(controller.state.view?.week.published, isFalse);
  });

  test('network error does not logout and keeps retry', () async {
    api.throwError = const ApiException(
      code: ApiErrorCode.network,
      message: 'offline',
    );
    final controller = ScheduleController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.error);
    expect(controller.state.errorMessage, isNotNull);
  });

  test('401 is delegated to auth and does not become a schedule error', () async {
    api.throwError = const ApiException(
      code: ApiErrorCode.unauthenticated,
      message: 'Unauthenticated.',
      statusCode: 401,
    );
    final controller = ScheduleController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.loading);
    expect(controller.state.errorMessage, isNull);
  });

  test('parent child id is transmitted', () async {
    final controller = ScheduleController(
      repository: repository,
      kind: ScheduleKind.child,
      studentId: 42,
    );
    await controller.loadCurrent();
    expect(api.childLoads, 1);
    expect(api.studentLoads, 0);
    expect(api.lastStudentId, 42);
    expect(controller.lastRequestedStudentId, 42);
  });

  test('teacher endpoint is called and isolated from student cache', () async {
    api.responses['current'] = ScheduleWeekView.fromJson(teacherScheduleJson());
    final teacherController = ScheduleController(
      repository: repository,
      kind: ScheduleKind.teacher,
    );
    await teacherController.loadCurrent();
    expect(api.teacherLoads, 1);
    expect(api.studentLoads, 0);
    expect(teacherController.lastRequestedKind, ScheduleKind.teacher);
    expect(teacherController.state.view?.teacher?.displayName, 'Maria Rossi');
    expect(teacherController.state.view?.days.first.lessons.single.academyClass?.name, 'Classe A');

    final studentController = ScheduleController(repository: repository);
    api.responses['current'] = ScheduleWeekView.fromJson(publishedScheduleJson());
    await studentController.loadCurrent();
    expect(api.studentLoads, 1);
    expect(api.teacherLoads, 1);
  });

  test('teacher unpublished week', () async {
    api.responses['current'] = ScheduleWeekView.fromJson(
      teacherEmptyScheduleJson(published: false),
    );
    final controller = ScheduleController(
      repository: repository,
      kind: ScheduleKind.teacher,
    );
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.unpublished);
  });

  test('teacher network error', () async {
    final errorApi = FakeScheduleApi()
      ..throwError = const ApiException(code: ApiErrorCode.network, message: 'offline');
    final controller = ScheduleController(
      repository: ScheduleRepository(api: errorApi),
      kind: ScheduleKind.teacher,
    );
    await controller.loadCurrent();
    expect(controller.state.status, ScheduleStatus.error);
  });
}
