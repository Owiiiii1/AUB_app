import 'package:flutter/material.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class ChildContextHeader extends StatelessWidget {
  const ChildContextHeader({
    super.key,
    required this.child,
    this.caption,
  });

  final ParentChild child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final className = child.academyClass?.name;
    return AubCard(
      padding: const EdgeInsets.all(AubSpacing.sm),
      child: Row(
        children: [
          AubAvatar(size: 48, name: child.displayName),
          const SizedBox(width: AubSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (caption != null && caption!.isNotEmpty)
                  Text(
                    caption!.toUpperCase(),
                    style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
                  ),
                Text(
                  child.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AubText.headlineSm,
                ),
                if (className != null && className.isNotEmpty)
                  Text(
                    className,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AubText.bodySm,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
