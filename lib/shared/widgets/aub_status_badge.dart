import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';

enum AubBadgeTone { success, warning, alert, muted, gold }

class AubStatusBadge extends StatelessWidget {
  const AubStatusBadge({
    super.key,
    required this.label,
    this.tone = AubBadgeTone.muted,
    this.icon,
  });

  final String label;
  final AubBadgeTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (fg, bg) = switch (tone) {
      AubBadgeTone.success => (AubColors.success, AubColors.successBg),
      AubBadgeTone.warning => (AubColors.warning, AubColors.warningBg),
      AubBadgeTone.alert => (AubColors.alert, AubColors.alertBg),
      AubBadgeTone.gold => (AubColors.gold, AubColors.goldLight),
      AubBadgeTone.muted => (AubColors.textSecondary, AubColors.surfaceSubtle),
    };

    return Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: AubSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AubRadii.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: AubText.labelCaps.copyWith(color: fg),
          ),
        ],
      ),
    );
  }
}
