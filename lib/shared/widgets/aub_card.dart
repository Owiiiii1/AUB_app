import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';

class AubCard extends StatelessWidget {
  const AubCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.stripColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? stripColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? AubColors.surfaceCard,
        borderRadius: BorderRadius.circular(AubRadii.xxl),
        border: Border.all(color: AubColors.borderMuted),
        boxShadow: const [
          BoxShadow(
            color: AubColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AubRadii.xxl),
        child: Stack(
          children: [
            if (stripColor != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: Container(width: 3, color: stripColor),
              ),
            Padding(
              padding: padding ?? const EdgeInsets.all(AubSpacing.md),
              child: child,
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return content;
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AubRadii.xxl),
        child: content,
      ),
    );
  }
}
