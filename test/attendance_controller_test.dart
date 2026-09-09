import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/features/attendance/state/attendance_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/fake_attendance_api.dart';

void main() {
  late FakeAttendanceApi api;
  late AttendanceController controller;

  setUp(() {
    api = FakeAttendanceApi()..roster = attendanceRoster();
    controller = AttendanceController(
      repository: AttendanceRepository(api: api),
      lessonId: 123,
    );
  });

  test('load populates roster', () async {
    await controller.load();
    expect(controller.state.status, AttendanceLoadStatus.loaded);
    expect(controller.state.roster?.students, hasLength(2));
    expect(api.loads, 1);
    expect(controller.isDirty, isFalse);
    expect(controller.canSave, isFalse);
  });

  test('mark present absent excused and all present dirty the state', () async {
    await controller.load();
    final bruno = controller.state.roster!.students[1];
    controller.mark(bruno.id, AttendanceStatus.present);
    expect(controller.statusOf(bruno), AttendanceStatus.present);
    expect(controller.isDirty, isTrue);

    controller.mark(bruno.id, AttendanceStatus.absent);
    expect(controller.statusOf(bruno), AttendanceStatus.absent);

    controller.mark(bruno.id, AttendanceStatus.excused);
    expect(controller.statusOf(bruno), AttendanceStatus.excused);

    controller.markAllPresent();
    expect(
      controller.state.roster!.students.every(
        (student) => controller.statusOf(student) == AttendanceStatus.present,
      ),
      isTrue,
    );
    expect(controller.canSave, isTrue);
  });

  test('save success becomes the new source of truth', () async {
    await controller.load();
    controller.mark(101, AttendanceStatus.absent);
    api.roster = AttendanceRoster.fromJson(
      attendanceRosterJson(
        students: [
          {
            'id': 100,
            'display_name': 'Anna Rossi',
            'photo_url': null,
            'attendance': {'status': 'present'},
          },
          {
            'id': 101,
            'display_name': 'Bruno Neri',
            'photo_url': null,
            'attendance': {'status': 'absent'},
          },
        ],
      ),
    );
    await controller.save();
    expect(api.saves, 1);
    expect(api.lastSave, isNotNull);
    expect(controller.isDirty, isFalse);
    expect(controller.statusOf(controller.state.roster!.students[1]), AttendanceStatus.absent);
    expect(controller.state.saving, isFalse);
  });

  test('save failure keeps local changes', () async {
    await controller.load();
    controller.mark(101, AttendanceStatus.absent);
    api.throwOnSave = const ApiException(
      code: ApiErrorCode.network,
      message: 'offline',
    );
    await controller.save();
    expect(controller.isDirty, isTrue);
    expect(controller.statusOf(controller.state.roster!.students[1]), AttendanceStatus.absent);
    expect(controller.state.errorMessage, isNotNull);
    expect(controller.canSave, isTrue);
  });

  test('401 does not become an attendance error', () async {
    api.throwOnLoad = const ApiException(
      code: ApiErrorCode.unauthenticated,
      message: 'Unauthenticated.',
      statusCode: 401,
    );
    await controller.load();
    expect(controller.state.status, AttendanceLoadStatus.loading);
    expect(controller.state.errorMessage, isNull);
  });

  test('cancelled roster is not dirty and cannot save', () async {
    api.roster = attendanceRoster(editable: false, reason: 'cancelled', status: 'cancelled');
    await controller.load();
    controller.mark(101, AttendanceStatus.present);
    controller.markAllPresent();
    expect(controller.statusOf(controller.state.roster!.students[1]), isNull);
    expect(controller.canSave, isFalse);
  });
}
