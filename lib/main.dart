import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/app/app.dart';
import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/storage/secure_token_storage.dart';
import 'package:aub/features/auth/data/auth_repository.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/attendance/data/attendance_api.dart';
import 'package:aub/features/attendance/data/attendance_history_repository.dart';
import 'package:aub/features/attendance/data/attendance_repository.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ensureAcademyTimeZones();

  final config = AppConfig.fromEnvironment();
  if (kReleaseMode && !config.usesHttps) {
    throw StateError('Release builds require an HTTPS API base URL.');
  }

  final apiClient = ApiClient(config: config);
  final tokenStorage = SecureTokenStorage();
  final repository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
  final controller = AuthController(repository: repository);
  apiClient.onUnauthorized = controller.handleUnauthorized;
  final scheduleRepository = ScheduleRepository(api: ScheduleApi(apiClient));
  final attendanceApi = AttendanceApi(apiClient);
  final attendanceRepository = AttendanceRepository(api: attendanceApi);
  final attendanceHistoryRepository = AttendanceHistoryRepository(
    api: attendanceApi,
  );
  final profileApi = ProfileApi(apiClient);
  final profilePreferences = ProfilePreferences(storage: tokenStorage.storage);

  runApp(
    AubApp(
      controller: controller,
      scheduleRepository: scheduleRepository,
      attendanceRepository: attendanceRepository,
      attendanceHistoryRepository: attendanceHistoryRepository,
      profileApi: profileApi,
      profilePreferences: profilePreferences,
    ),
  );
}
