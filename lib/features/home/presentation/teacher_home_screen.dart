import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/auth/models/actor_profile.dart';

class TeacherHomeScreen extends StatelessWidget {
  const TeacherHomeScreen({
    super.key,
    required this.profile,
    required this.onLogout,
    this.onOpenSchedule,
  });

  final TeacherProfile profile;
  final VoidCallback onLogout;
  final VoidCallback? onOpenSchedule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.appName),
        actions: [
          TextButton(
            onPressed: onLogout,
            child: const Text(AppStrings.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.displayName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            const Text(AppStrings.teacherArea),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onOpenSchedule,
              child: const Text(AppStrings.schedule),
            ),
          ],
        ),
      ),
    );
  }
}
