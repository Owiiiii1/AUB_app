import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';

class AubAppHeader extends StatelessWidget implements PreferredSizeWidget {
  const AubAppHeader({
    super.key,
    required this.title,
    this.profile,
    this.avatarName,
    this.photoUrl,
    this.onAvatarTap,
  });

  final String title;
  final StudentProfile? profile;
  final String? avatarName;
  final String? photoUrl;
  final VoidCallback? onAvatarTap;

  @override
  Size get preferredSize => const Size.fromHeight(AubSpacing.appBar);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AubColors.surfaceIvory,
      elevation: 8,
      shadowColor: AubColors.navShadow,
      surfaceTintColor: Colors.transparent,
      child: SafeArea(
        bottom: false,
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
                if (_avatarName != null)
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: AubAvatar(
                      size: 32,
                      photoUrl: _photoUrl,
                      name: _avatarName,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _avatarName => avatarName ?? profile?.displayName;

  String? get _photoUrl => photoUrl ?? profile?.photoUrl;
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
      color: AubColors.surfaceIvory,
      elevation: 12,
      shadowColor: AubColors.navShadow,
      surfaceTintColor: Colors.transparent,
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

enum ParentNavTab { home, children, calendar, profile }

class ParentBottomNav extends StatelessWidget {
  const ParentBottomNav({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final ParentNavTab selected;
  final ValueChanged<ParentNavTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AubColors.surfaceIvory,
      elevation: 12,
      shadowColor: AubColors.navShadow,
      surfaceTintColor: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.paddingOf(context).bottom,
        ),
        child: SizedBox(
          height: AubSpacing.bottomNav,
          child: Row(
            children: [
              _item(
                tab: ParentNavTab.home,
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: AppStrings.homeTab,
              ),
              _item(
                tab: ParentNavTab.children,
                icon: Icons.people_outline,
                selectedIcon: Icons.family_restroom,
                label: AppStrings.childrenTab,
              ),
              _item(
                tab: ParentNavTab.calendar,
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
                label: AppStrings.calendarTab,
              ),
              _item(
                tab: ParentNavTab.profile,
                icon: Icons.person_outline,
                selectedIcon: Icons.person,
                label: AppStrings.profileTab,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item({
    required ParentNavTab tab,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final isSelected = selected == tab;
    final color = isSelected ? AubColors.navy : AubColors.textMuted;
    return Expanded(
      child: InkWell(
        key: Key('parent-nav-${tab.name}'),
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
