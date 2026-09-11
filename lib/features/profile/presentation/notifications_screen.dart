import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key, required this.preferences});

  final ProfilePreferences preferences;

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late bool _enabled;

  @override
  void initState() {
    super.initState();
    _enabled = widget.preferences.pushEnabled;
  }

  Future<void> _toggle(bool value) async {
    await widget.preferences.setPushEnabled(value);
    setState(() => _enabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      appBar: AppBar(title: const Text(AppStrings.pushNotifications)),
      body: ListView(
        padding: const EdgeInsets.all(AubSpacing.margin),
        children: [
          AubCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: _enabled,
              onChanged: _toggle,
              title: Text(AppStrings.pushNotifications, style: AubText.bodyMd),
              subtitle: Text(AppStrings.pushHint, style: AubText.labelSm),
            ),
          ),
          const SizedBox(height: AubSpacing.md),
          const Text(
            AppStrings.pushUnavailable,
            style: AubText.bodySm,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
