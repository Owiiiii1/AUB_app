import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/features/attendance/state/attendance_history_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/attendance_fixtures.dart';
import 'helpers/fake_attendance_api.dart';

void main() {
  late FakeAttendanceApi api;
  late AttendanceHistoryRepository repository;

  setUp(() {
    api = FakeAttendanceApi()..history = attendanceHistory();
    repository = AttendanceHistoryRepository(api: api);
  });

  test('student endpoint loads current month', () async {
    final controller = AttendanceHistoryController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, AttendanceHistoryStatus.loaded);
    expect(controller.state.history?.records, hasLength(3));
    expect(api.historyLoads, 1);
    expect(api.lastHistoryStudentId, isNull);
    expect(api.lastHistoryMonth, isNull);
  });

  test('parent child endpoint uses student id', () async {
    final controller = AttendanceHistoryController(
      repository: repository,
      studentId: 8,
    );
    await controller.load(month: '2026-09');
    expect(api.lastHistoryStudentId, 8);
    expect(api.lastHistoryMonth, '2026-09');
    expect(controller.lastRequestedStudentId, 8);
  });

  test('previous next and current month', () async {
    final controller = AttendanceHistoryController(repository: repository);
    await controller.load(month: '2026-09');
    expect(controller.state.history?.period.month, '2026-09');

    api.history = attendanceHistory(month: '2026-08');
    await controller.loadPrevious();
    expect(api.lastHistoryMonth, '2026-08');
    expect(controller.state.history?.period.month, '2026-08');

    await controller.loadNext();
    expect(controller.state.history?.period.month, '2026-09');

    await controller.loadCurrent();
    expect(api.lastHistoryMonth, isNull);
  });

  test('empty month becomes empty status', () async {
    api.history = attendanceHistory(
      marked: 0,
      present: 0,
      absent: 0,
      excused: 0,
      records: const [],
    );
    final controller = AttendanceHistoryController(repository: repository);
    await controller.load(month: '2026-08');
    expect(controller.state.status, AttendanceHistoryStatus.empty);
    expect(controller.state.history?.records, isEmpty);
  });

  test('network error keeps retry without logout', () async {
    api.throwOnHistory = const ApiException(
      code: ApiErrorCode.network,
      message: 'offline',
    );
    final controller = AttendanceHistoryController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, AttendanceHistoryStatus.error);
    expect(controller.state.errorMessage, isNotNull);

    api.throwOnHistory = null;
    await controller.retry();
    expect(controller.state.status, AttendanceHistoryStatus.loaded);
  });

  test('401 is handled globally without local error', () async {
    api.throwOnHistory = const ApiException(
      code: ApiErrorCode.unauthenticated,
      message: 'Unauthenticated.',
      statusCode: 401,
    );
    final controller = AttendanceHistoryController(repository: repository);
    await controller.loadCurrent();
    expect(controller.state.status, AttendanceHistoryStatus.loading);
    expect(controller.state.errorMessage, isNull);
  });

  test('student and parent caches are isolated', () async {
    await repository.loadStudentAttendance(month: '2026-09');
    await repository.loadChildAttendance(studentId: 8, month: '2026-09');
    expect(api.historyLoads, 2);
    await repository.loadStudentAttendance(month: '2026-09');
    await repository.loadChildAttendance(studentId: 8, month: '2026-09');
    expect(api.historyLoads, 2);
    await repository.loadChildAttendance(studentId: 9, month: '2026-09');
    expect(api.historyLoads, 3);
  });
}
