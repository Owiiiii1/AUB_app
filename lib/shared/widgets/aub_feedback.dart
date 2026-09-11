import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';

class AubEmptyState extends StatelessWidget {
  const AubEmptyState({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AubSpacing.md,
        vertical: AubSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon ?? Icons.event_busy_outlined,
            size: 28,
            color: AubColors.textMuted,
          ),
          const SizedBox(height: AubSpacing.sm),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AubText.bodySm.copyWith(color: AubColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class AubErrorState extends StatelessWidget {
  const AubErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AubSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: AubText.bodyMd,
            ),
            const SizedBox(height: AubSpacing.md),
            FilledButton(
              onPressed: onRetry,
              child: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }
}

class AubLoading extends StatelessWidget {
  const AubLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AubColors.navy),
    );
  }
}

class AubSectionTitle extends StatelessWidget {
  const AubSectionTitle({
    super.key,
    required this.title,
    this.trailing,
    this.count,
  });

  final String title;
  final Widget? trailing;
  final int? count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: AubText.headlineSm,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: AubSpacing.xs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AubSpacing.xs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AubColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(AubRadii.pill),
                  ),
                  child: Text('$count', style: AubText.labelSm),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
