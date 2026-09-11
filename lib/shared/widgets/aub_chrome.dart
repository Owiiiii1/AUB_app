import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';

class AubAppHeader extends StatelessWidget {
  const AubAppHeader({
    super.key,
    required this.title,
    this.profile,
    this.onAvatarTap,
  });

  final String title;
  final StudentProfile? profile;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AubColors.surfaceIvory.withValues(alpha: 0.94),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: SizedBox(
          height: AubSpacing.appBar,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AubSpacing.margin),
            child: Row(
              children: [
                const _AubMark(),
                const SizedBox(width: AubSpacing.sm),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.academyMark.toUpperCase(),
                        style: AubText.labelCaps,
                      ),
                      Text(
                        title.toUpperCase(),
                        style: AubText.headlineSm.copyWith(height: 1),
                      ),
                    ],
                  ),
                ),
                if (profile != null)
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: AubAvatar(
                      size: 32,
                      photoUrl: profile!.photoUrl,
                      name: profile!.displayName,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AubMark extends StatelessWidget {
  const _AubMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AubRadii.md),
        border: Border.all(color: AubColors.burgundy.withValues(alpha: 0.35)),
        color: AubColors.burgundyLight,
      ),
      child: Text(
        'AUB',
        style: AubText.labelCaps.copyWith(
          color: AubColors.burgundy,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

enum StudentNavTab { home, schedule, attendance, profile }

class AubBottomNav extends StatelessWidget {
  const AubBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final StudentNavTab selected;
  final ValueChanged<StudentNavTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AubColors.surfaceIvory.withValues(alpha: 0.94),
      elevation: 0,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AubColors.borderMuted)),
          boxShadow: [
            BoxShadow(
              color: AubColors.navShadow,
              blurRadius: 12,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom,
          ),
          child: SizedBox(
            height: AubSpacing.bottomNav,
            child: Row(
              children: [
                _item(
                  tab: StudentNavTab.home,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  label: AppStrings.homeTab,
                ),
                _item(
                  tab: StudentNavTab.schedule,
                  icon: Icons.calendar_today_outlined,
                  selectedIcon: Icons.calendar_today,
                  label: AppStrings.schedule,
                ),
                _item(
                  tab: StudentNavTab.attendance,
                  icon: Icons.fact_check_outlined,
                  selectedIcon: Icons.fact_check,
                  label: AppStrings.attendance,
                ),
                _item(
                  tab: StudentNavTab.profile,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  label: AppStrings.profileTab,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _item({
    required StudentNavTab tab,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selected == tab;
    final color = isSelected ? AubColors.navy : AubColors.textMuted;
    return Expanded(
      child: InkWell(
        key: Key('student-nav-${tab.name}'),
        onTap: () => onSelect(tab),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 3,
              width: 22,
              margin: const EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: isSelected ? AubColors.gold : Colors.transparent,
                borderRadius: BorderRadius.circular(AubRadii.pill),
              ),
            ),
            Icon(isSelected ? selectedIcon : icon, size: 22, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: AubText.labelSm.copyWith(
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
