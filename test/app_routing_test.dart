import 'package:aub/app/app.dart';
import 'package:aub/features/auth/presentation/login_screen.dart';
import 'package:aub/features/auth/presentation/splash_screen.dart';
import 'package:aub/features/home/presentation/parent_home_screen.dart';
import 'package:aub/features/home/presentation/student_home_screen.dart';
import 'package:aub/features/home/presentation/teacher_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/auth_fixtures.dart';
import 'helpers/memory_token_storage.dart';
import 'helpers/fake_auth_api.dart';
import 'package:aub/app/app_config.dart';
import 'package:aub/core/api/api_client.dart';
import 'package:aub/features/auth/data/auth_repository.dart';
import 'package:aub/features/auth/state/auth_controller.dart';
import 'package:aub/features/schedule/data/schedule_api.dart';
import 'package:aub/features/schedule/data/schedule_repository.dart';

void main() {
  testWidgets('initial state shows splash', (tester) async {
    final config = AppConfig(apiBaseUrl: testApiBaseUrl);
    final apiClient = ApiClient(config: config);
    final repository = AuthRepository(
      apiClient: apiClient,
      tokenStorage: PendingTokenStorage(),
      authApi: FakeAuthApi(apiClient),
      deviceName: () => 'AUB Test',
    );
    final controller = AuthController(repository: repository);

    await tester.pumpWidget(
      AubApp(
        controller: controller,
        scheduleRepository: ScheduleRepository(api: ScheduleApi(apiClient)),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('unauthenticated shows login', (tester) async {
    final harness = createHarness();
    await tester.pumpWidget(
      AubApp(
        controller: harness.controller,
        scheduleRepository: harness.scheduleRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Accedi'), findsWidgets);
  });

  testWidgets('student session shows student home', (tester) async {
    final harness = createHarness(storedToken: 'token');
    harness.authApi.meJson = studentMeJson(photoUrl: null);
    await tester.pumpWidget(
      AubApp(
        controller: harness.controller,
        scheduleRepository: harness.scheduleRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(StudentHomeScreen), findsOneWidget);
    expect(find.text('Ciao, Mario Rossi'), findsOneWidget);
    expect(find.textContaining('Prima A'), findsOneWidget);
    expect(find.textContaining('2026/2027'), findsOneWidget);
  });

  testWidgets('parent session shows parent home', (tester) async {
    final harness = createHarness(storedToken: 'token');
    harness.authApi.meJson = parentMeJson();
    await tester.pumpWidget(
      AubApp(
        controller: harness.controller,
        scheduleRepository: harness.scheduleRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ParentHomeScreen), findsOneWidget);
    expect(find.text('Maria Verdi'), findsOneWidget);
    expect(find.text('Giulia Verdi'), findsOneWidget);
    expect(find.textContaining('Own Class'), findsOneWidget);
  });

  testWidgets('teacher session shows teacher home', (tester) async {
    final harness = createHarness(storedToken: 'token');
    harness.authApi.meJson = teacherMeJson();
    await tester.pumpWidget(
      AubApp(
        controller: harness.controller,
        scheduleRepository: harness.scheduleRepository,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TeacherHomeScreen), findsOneWidget);
    expect(find.text('Elena Bianchi'), findsOneWidget);
    expect(find.text('Area docente'), findsOneWidget);
  });
}
