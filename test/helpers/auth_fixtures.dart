import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/auth/data/auth_repository.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';
import 'fake_auth_api.dart';
import 'memory_token_storage.dart';

const testApiBaseUrl = 'https://aub.owlsolutions.net/api/v1';

Map<String, dynamic> studentMeJson({
  String displayName = 'Mario Rossi',
  String? photoUrl = 'https://aub.owlsolutions.net/storage/students/1.jpg',
}) {
  return {
    'user': {
      'id': 10,
      'name': 'Mario Rossi',
      'email': 'mario@example.test',
      'account_type': 'student',
    },
    'profile': {
      'id': 1,
      'first_name': 'Mario',
      'last_name': 'Rossi',
      'display_name': displayName,
      'photo_url': photoUrl,
      'academy_class': {'id': 3, 'name': 'Prima A'},
      'academic_year': {'id': 7, 'name': '2026/2027'},
    },
  };
}

Map<String, dynamic> parentMeJson() {
  return {
    'user': {
      'id': 11,
      'name': 'Maria Verdi',
      'email': 'parent@example.test',
      'account_type': 'parent',
    },
    'profile': {
      'id': 2,
      'first_name': 'Maria',
      'last_name': 'Verdi',
      'display_name': 'Maria Verdi',
      'children': [
        {
          'id': 1,
          'first_name': 'Giulia',
          'last_name': 'Verdi',
          'display_name': 'Giulia Verdi',
          'academy_class': {'id': 3, 'name': 'Own Class'},
        },
      ],
    },
  };
}

Map<String, dynamic> teacherMeJson() {
  return {
    'user': {
      'id': 12,
      'name': 'Elena Bianchi',
      'email': 'teacher@example.test',
      'account_type': 'teacher',
    },
    'profile': {
      'id': 4,
      'first_name': 'Elena',
      'last_name': 'Bianchi',
      'display_name': 'Elena Bianchi',
    },
  };
}

AuthHarness createHarness({String? storedToken}) {
  final config = AppConfig(apiBaseUrl: testApiBaseUrl);
  final apiClient = ApiClient(config: config);
  final storage = MemoryTokenStorage(storedToken);
  final authApi = FakeAuthApi(apiClient);
  final repository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: storage,
    authApi: authApi,
    deviceName: () => 'AUB Test',
  );
  final controller = AuthController(repository: repository);
  apiClient.onUnauthorized = controller.handleUnauthorized;
  final scheduleRepository = ScheduleRepository(api: ScheduleApi(apiClient));
  final attendanceApi = AttendanceApi(apiClient);
  final attendanceRepository = AttendanceRepository(api: attendanceApi);
  final attendanceHistoryRepository = AttendanceHistoryRepository(
    api: attendanceApi,
  );
  return AuthHarness(
    apiClient: apiClient,
    storage: storage,
    authApi: authApi,
    repository: repository,
    controller: controller,
    scheduleRepository: scheduleRepository,
    attendanceRepository: attendanceRepository,
    attendanceHistoryRepository: attendanceHistoryRepository,
  );
}

class AuthHarness {
  AuthHarness({
    required this.apiClient,
    required this.storage,
    required this.authApi,
    required this.repository,
    required this.controller,
    required this.scheduleRepository,
    required this.attendanceRepository,
    required this.attendanceHistoryRepository,
  });

  final ApiClient apiClient;
  final MemoryTokenStorage storage;
  final FakeAuthApi authApi;
  final AuthRepository repository;
  final AuthController controller;
  final ScheduleRepository scheduleRepository;
  final AttendanceRepository attendanceRepository;
  final AttendanceHistoryRepository attendanceHistoryRepository;
}
