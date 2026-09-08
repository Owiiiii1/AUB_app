import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/features/auth/models/actor_profile.dart';

class ParentHomeScreen extends StatelessWidget {
  const ParentHomeScreen({
    super.key,
    required this.profile,
    required this.onLogout,
  });

  final ParentProfile profile;
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
              (child) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(child.displayName),
                subtitle: Text(
                  '${AppStrings.classLabel}: ${child.academyClass?.name ?? AppStrings.noClass}',
                ),
              ),
            ),
        ],
      ),
    );
  }
}
