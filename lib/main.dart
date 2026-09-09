import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:aub/app/app.dart';
import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/core/storage/secure_token_storage.dart';
import 'package:aub/features/auth/data/auth_repository.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  if (kReleaseMode && !config.usesHttps) {
    throw StateError('Release builds require an HTTPS API base URL.');
  }

  final apiClient = ApiClient(config: config);
  final repository = AuthRepository(
    apiClient: apiClient,
    tokenStorage: SecureTokenStorage(),
  );
  final controller = AuthController(repository: repository);
  apiClient.onUnauthorized = controller.handleUnauthorized;
  final scheduleRepository = ScheduleRepository(api: ScheduleApi(apiClient));

  runApp(
    AubApp(
      controller: controller,
      scheduleRepository: scheduleRepository,
    ),
  );
}
