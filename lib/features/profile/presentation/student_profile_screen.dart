import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/auth/models/api_user.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({
    super.key,
    required this.profile,
    required this.user,
    required this.onLogout,
  });

  final StudentProfile profile;
  final ApiUser user;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final className = profile.academyClass?.name;
    final yearName = profile.academicYear?.name;

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
              AubAvatar(
                size: 96,
                photoUrl: profile.photoUrl,
                name: profile.displayName,
              ),
              const SizedBox(height: AubSpacing.sm),
              Text(profile.displayName, style: AubText.headlineMd),
              if (className != null && className.isNotEmpty) ...[
                const SizedBox(height: AubSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AubSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AubColors.burgundyLight,
                    borderRadius: BorderRadius.circular(AubRadii.pill),
                  ),
                  child: Text(
                    className.toUpperCase(),
                    style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
                  ),
                ),
              ],
              const SizedBox(height: AubSpacing.sm),
              if (yearName != null && yearName.isNotEmpty)
                Text(
                  '${AppStrings.yearLabel}: $yearName',
                  style: AubText.labelSm,
                ),
              const SizedBox(height: 4),
              Text(
                user.email,
                style: AubText.bodySm,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: AubSpacing.lg),
        AubCard(
          padding: EdgeInsets.zero,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
            onTap: () => _confirmLogout(context),
            child: Padding(
              padding: const EdgeInsets.all(AubSpacing.md),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AubColors.alertBg,
                      borderRadius: BorderRadius.circular(AubRadii.lg),
                    ),
                    child: const Icon(
                      Icons.logout,
                      color: AubColors.alert,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AubSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.logoutAccount,
                          style: AubText.bodyMd.copyWith(
                            color: AubColors.alert,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(AppStrings.logoutHint, style: AubText.labelSm),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward, color: AubColors.alert, size: 20),
                ],
              ),
            ),
            ),
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
      onLogout();
    }
  }
}
