import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';

class ChildSwitcher extends StatelessWidget {
  const ChildSwitcher({
    super.key,
    required this.children,
    required this.selected,
    required this.onSelect,
  });

  final List<ParentChild> children;
  final ParentChild? selected;
  final ValueChanged<ParentChild> onSelect;

  @override
  Widget build(BuildContext context) {
    final current = selected;
    if (current == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AubSpacing.md,
        vertical: AubSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AubColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AubRadii.lg),
      ),
      child: Row(
        children: [
          const Icon(Icons.stars, size: 18, color: AubColors.gold),
          const SizedBox(width: AubSpacing.xs),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: AubText.bodySm,
                children: [
                  const TextSpan(text: 'Stai visualizzando: '),
                  TextSpan(
                    text: current.displayName,
                    style: AubText.labelMd.copyWith(color: AubColors.textPrimary),
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (children.length > 1)
            TextButton(
              key: const Key('parent-change-child'),
              onPressed: () => _openPicker(context),
              style: TextButton.styleFrom(
                foregroundColor: AubColors.burgundy,
                visualDensity: VisualDensity.compact,
              ),
              child: const Text(AppStrings.changeStudent),
            ),
        ],
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<ParentChild>(
      context: context,
      backgroundColor: AubColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AubRadii.xxl)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(AppStrings.changeStudent, style: AubText.headlineSm),
                const SizedBox(height: AubSpacing.md),
                for (final child in children)
                  ListTile(
                    key: Key('parent-select-child-${child.id}'),
                    leading: AubAvatar(size: 40, name: child.displayName, photoUrl: child.photoUrl),
                    title: Text(child.displayName),
                    subtitle: child.academyClass == null
                        ? null
                        : Text(child.academyClass!.name),
                    selected: selected?.id == child.id,
                    onTap: () => Navigator.of(context).pop(child),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      onSelect(picked);
    }
  }
}
