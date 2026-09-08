import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/media/safe_https_url.dart';
import 'package:aub/features/auth/models/actor_profile.dart';

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  final StudentProfile profile;
  final VoidCallback onLogout;

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
          if (isSafeHttpsUrl(profile.photoUrl))
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                radius: 36,
                backgroundImage: NetworkImage(profile.photoUrl!),
                onBackgroundImageError: (_, _) {},
              ),
            ),
          if (isSafeHttpsUrl(profile.photoUrl)) const SizedBox(height: 16),
          Text(
            'Ciao, ${profile.displayName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text('${AppStrings.classLabel}: ${profile.academyClass?.name ?? AppStrings.noClass}'),
          const SizedBox(height: 8),
          Text('${AppStrings.yearLabel}: ${profile.academicYear?.name ?? '—'}'),
        ],
      ),
    );
  }
}
