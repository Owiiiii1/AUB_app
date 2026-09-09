import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/auth/models/actor_profile.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({
    super.key,
    required this.profile,
    required this.onLogout,
    this.onOpenChildSchedule,
    this.onOpenChildAttendance,
  });

  final ParentProfile profile;
  final VoidCallback onLogout;
  final ValueChanged<ParentChild>? onOpenChildSchedule;
  final ValueChanged<ParentChild>? onOpenChildAttendance;

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
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            profile.displayName,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.childrenLabel,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (profile.children.isEmpty)
            const Text('—')
          else
            ...profile.children.map(
              (child) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      '${AppStrings.classLabel}: ${child.academyClass?.name ?? AppStrings.noClass}',
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        FilledButton(
                          onPressed: onOpenChildSchedule == null
                              ? null
                              : () => onOpenChildSchedule!(child),
                          child: const Text(AppStrings.schedule),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: onOpenChildAttendance == null
                              ? null
                              : () => onOpenChildAttendance!(child),
                          child: const Text(AppStrings.attendance),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
