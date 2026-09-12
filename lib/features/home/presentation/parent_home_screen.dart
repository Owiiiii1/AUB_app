import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/clock.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/features/auth/models/actor_profile.dart';
import 'package:aub/features/home/state/parent_home_controller.dart';
import 'package:aub/features/home/state/parent_home_state.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/child_card.dart';

class ParentHomeScreen extends StatefulWidget {
  const ParentHomeScreen({
    super.key,
    required this.profile,
    required this.controller,
    this.onSelectChild,
    this.onOpenChildSchedule,
    this.onOpenChildAttendance,
    this.onOpenCalendar,
  });

  final ParentProfile profile;
  final ParentHomeController controller;
  final ValueChanged<ParentChild>? onSelectChild;
  final ValueChanged<ParentChild>? onOpenChildSchedule;
  final ValueChanged<ParentChild>? onOpenChildAttendance;
  final VoidCallback? onOpenCalendar;

  @override
  State<ParentHomeScreen> createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.controller.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final state = widget.controller.state;
        return switch (state.status) {
          ParentHomeStatus.loading => const AubLoading(),
          ParentHomeStatus.error => AubErrorState(
              message: state.errorMessage ?? AppStrings.serverError,
              onRetry: widget.controller.retry,
            ),
          ParentHomeStatus.loaded => _ParentHomeLoaded(
              profile: widget.profile,
              state: state,
              onSelectChild: widget.onSelectChild,
              onOpenChildSchedule: widget.onOpenChildSchedule,
              onOpenChildAttendance: widget.onOpenChildAttendance,
              onOpenCalendar: widget.onOpenCalendar,
            ),
        };
      },
    );
  }
}

class _ParentHomeLoaded extends StatelessWidget {
  const _ParentHomeLoaded({
    required this.profile,
    required this.state,
    this.onSelectChild,
    this.onOpenChildSchedule,
    this.onOpenChildAttendance,
    this.onOpenCalendar,
  });

  final ParentProfile profile;
  final ParentHomeState state;
  final ValueChanged<ParentChild>? onSelectChild;
  final ValueChanged<ParentChild>? onOpenChildSchedule;
  final ValueChanged<ParentChild>? onOpenChildAttendance;
  final VoidCallback? onOpenCalendar;

  @override
  Widget build(BuildContext context) {
    final now = state.now ?? const AcademyClock().now();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.xs,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        Text(
          AppStrings.parentGreeting(profile.givenName, now),
          style: AubText.headlineLg,
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.enrolledCount(profile.children.length),
          style: AubText.bodySm,
        ),
        const SizedBox(height: AubSpacing.xl),
        AubSectionTitle(
          title: AppStrings.yourChildren,
          trailing: Text(
            AppStrings.pupilsCount(profile.children.length).toUpperCase(),
            style: AubText.labelCaps,
          ),
        ),
        const SizedBox(height: AubSpacing.sm),
        if (profile.children.isEmpty)
          const AubCard(
            child: AubEmptyState(message: AppStrings.noChildren),
          )
        else
          ...[
            for (final dashboard in state.dashboards) ...[
              ChildCard(
                dashboard: dashboard,
                now: now,
                onTap: onSelectChild == null
                    ? null
                    : () => onSelectChild!(dashboard.child),
                onOpenSchedule: onOpenChildSchedule == null
                    ? null
                    : () => onOpenChildSchedule!(dashboard.child),
                onOpenAttendance: onOpenChildAttendance == null
                    ? null
                    : () => onOpenChildAttendance!(dashboard.child),
              ),
              const SizedBox(height: AubSpacing.md),
            ],
          ],
        AubSectionTitle(
          title: AppStrings.upcomingCommitments,
          trailing: onOpenCalendar == null
              ? null
              : TextButton(
                  onPressed: onOpenCalendar,
                  child: Text(
                    AppStrings.seeAll,
                    style: AubText.labelMd.copyWith(color: AubColors.burgundy),
                  ),
                ),
        ),
        const SizedBox(height: AubSpacing.sm),
        if (state.upcoming.isEmpty)
          const AubCard(
            child: AubEmptyState(message: AppStrings.noUpcomingLesson),
          )
        else
          AubCard(
            child: Column(
              children: [
                for (var i = 0; i < state.upcoming.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 20, color: AubColors.borderHairline),
                  _UpcomingRow(item: state.upcoming[i], now: now),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({required this.item, required this.now});

  final ChildUpcoming item;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final room = item.lesson.location?.room?.name;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
          decoration: BoxDecoration(
            color: AubColors.burgundyLight,
            borderRadius: BorderRadius.circular(AubRadii.lg),
          ),
          child: Column(
            children: [
              Text(
                _dayChip(item.day.date, now),
                style: AubText.labelCaps.copyWith(color: AubColors.burgundy),
              ),
              Text(
                item.lesson.startsAt,
                style: AubText.headlineSm.copyWith(height: 1.1),
              ),
            ],
          ),
        ),
        const SizedBox(width: AubSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.lesson.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AubText.headlineSm,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AubColors.burgundy,
                      borderRadius: BorderRadius.circular(AubRadii.pill),
                    ),
                    child: Text(
                      item.child.givenName.toUpperCase(),
                      style: AubText.labelCaps.copyWith(color: Colors.white),
                    ),
                  ),
                ],
              ),
              if (room != null && room.isNotEmpty)
                Text(
                  room,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AubText.bodySm,
                ),
            ],
          ),
        ),
      ],
    );
  }

  String _dayChip(DateTime date, DateTime academyNow) {
    final today = DateTime(academyNow.year, academyNow.month, academyNow.day);
    if (isSameDate(date, today)) {
      return AppStrings.today;
    }
    final tomorrow = today.add(const Duration(days: 1));
    if (isSameDate(date, tomorrow)) {
      return 'Domani';
    }
    return DateFormat('d MMM', 'it').format(date);
  }
}
