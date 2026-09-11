import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';

class ProfileMenuRow extends StatelessWidget {
  const ProfileMenuRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor = AubColors.navy,
    this.iconBackground = AubColors.goldLight,
    this.titleColor = AubColors.textPrimary,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color iconColor;
  final Color iconBackground;
  final Color titleColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AubSpacing.md),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(AubRadii.lg),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: AubSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AubText.bodyMd.copyWith(
                        color: titleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(subtitle, style: AubText.labelSm),
                  ],
                ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward,
                    color: titleColor == AubColors.alert
                        ? AubColors.alert
                        : AubColors.textMuted,
                    size: 20,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
