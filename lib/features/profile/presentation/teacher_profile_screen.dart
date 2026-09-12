import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/data/profile_preferences.dart';
import 'package:aub/features/profile/presentation/change_password_screen.dart';
import 'package:aub/features/profile/presentation/devices_screen.dart';
import 'package:aub/features/profile/presentation/language_screen.dart';
import 'package:aub/features/profile/presentation/notifications_screen.dart';
import 'package:aub/features/profile/presentation/profile_menu_row.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({
    super.key,
    required this.profile,
    required this.user,
    required this.onLogout,
    this.profileApi,
    this.preferences,
  });

  final TeacherProfile profile;
  final ApiUser user;
  final VoidCallback onLogout;
  final ProfileApi? profileApi;
  final ProfilePreferences? preferences;

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  late final ProfilePreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? ProfilePreferences();
    _preferences.load().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = widget.profileApi;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        Text(
          AppStrings.academyName.toUpperCase(),
          style: AubText.labelCaps,
        ),
        Text(AppStrings.myProfile, style: AubText.headlineLg),
        const SizedBox(height: AubSpacing.lg),
        AubCard(
          padding: const EdgeInsets.fromLTRB(
            AubSpacing.lg,
            AubSpacing.lg,
            AubSpacing.lg,
            AubSpacing.md,
          ),
          child: Column(
            children: [
              AubAvatar(size: 96, name: widget.profile.displayName),
              const SizedBox(height: AubSpacing.sm),
              Text(
                widget.profile.displayName,
                style: AubText.headlineMd,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                AppStrings.teacherRole,
                style: AubText.bodySm,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                widget.user.email,
                style: AubText.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AubSpacing.lg),
        Text(AppStrings.securityAccess.toUpperCase(), style: AubText.labelCaps),
        const SizedBox(height: AubSpacing.xs),
        AubCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              if (api != null)
                ProfileMenuRow(
                  icon: Icons.lock_outline,
                  title: AppStrings.changePassword,
                  subtitle: AppStrings.changePasswordHint,
                  onTap: () => _openPassword(api),
                ),
              if (api != null)
                const Divider(height: 1, color: AubColors.borderHairline),
              if (api != null)
                ProfileMenuRow(
                  icon: Icons.devices,
                  title: AppStrings.devices,
                  subtitle: AppStrings.devicesHint,
                  onTap: () => _openDevices(api),
                ),
              if (api != null)
                const Divider(height: 1, color: AubColors.borderHairline),
              ProfileMenuRow(
                icon: Icons.logout,
                iconColor: AubColors.alert,
                iconBackground: AubColors.alertBg,
                titleColor: AubColors.alert,
                title: AppStrings.logoutAccount,
                subtitle: AppStrings.logoutHint,
                onTap: () => _confirmLogout(context),
              ),
            ],
          ),
        ),
        const SizedBox(height: AubSpacing.lg),
        Text(
          AppStrings.preferencesLanguage.toUpperCase(),
          style: AubText.labelCaps,
        ),
        const SizedBox(height: AubSpacing.xs),
        AubCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ProfileMenuRow(
                icon: Icons.language,
                title: AppStrings.language,
                subtitle: _languageLabel(_preferences.language),
                onTap: _openLanguage,
              ),
              const Divider(height: 1, color: AubColors.borderHairline),
              ProfileMenuRow(
                icon: Icons.notifications_outlined,
                title: AppStrings.pushNotifications,
                subtitle: AppStrings.pushHint,
                onTap: _openNotifications,
              ),
            ],
          ),
        ),
        const SizedBox(height: AubSpacing.lg),
        Text(
          AppStrings.academyMark.toUpperCase(),
          textAlign: TextAlign.center,
          style: AubText.labelCaps.copyWith(color: AubColors.textMuted),
        ),
      ],
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'en' => AppStrings.languageEnglish,
      'ru' => AppStrings.languageRussian,
      _ => AppStrings.languageItalian,
    };
  }

  Future<void> _openPassword(ProfileApi api) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ChangePasswordScreen(api: api),
      ),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AppStrings.passwordChanged)),
      );
    }
  }

  Future<void> _openDevices(ProfileApi api) async {
    final loggedOutAll = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => DevicesScreen(api: api),
      ),
    );
    if (loggedOutAll == true) {
      widget.onLogout();
    }
  }

  Future<void> _openLanguage() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => LanguageScreen(preferences: _preferences),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(preferences: _preferences),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AubColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AubRadii.xxl)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AubColors.alertBg,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: AubColors.alert),
              ),
              const SizedBox(height: 12),
              Text(AppStrings.logoutConfirmTitle, style: AubText.headlineSm),
              const SizedBox(height: 8),
              Text(
                AppStrings.logoutConfirmBody,
                textAlign: TextAlign.center,
                style: AubText.bodySm,
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(backgroundColor: AubColors.alert),
                child: const Text(AppStrings.logoutConfirmAction),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(AppStrings.cancel),
              ),
            ],
          ),
        );
      },
    );
    if (confirmed == true) {
      widget.onLogout();
    }
  }
}
