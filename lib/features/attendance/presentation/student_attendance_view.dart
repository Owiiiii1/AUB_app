import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/time/date_only.dart';
import 'package:aub/core/time/italian_dates.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/state/attendance_history_controller.dart';
import 'package:aub/shared/widgets/aub_card.dart';
import 'package:aub/shared/widgets/aub_feedback.dart';
import 'package:aub/shared/widgets/aub_status_badge.dart';

class StudentAttendanceView extends StatelessWidget {
  const StudentAttendanceView({
    super.key,
    required this.history,
    required this.controller,
    required this.child,
  });

  final AttendanceHistory? history;
  final AttendanceHistoryController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AubSpacing.margin,
            AubSpacing.sm,
            AubSpacing.margin,
            0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              AppStrings.attendanceRegister.toUpperCase(),
              style: AubText.headlineLg,
            ),
          ),
        ),
        if (history != null)
          _MonthBar(month: history!.period.month, controller: controller),
        Expanded(child: child),
      ],
    );
  }
}

class StudentAttendanceRecords extends StatelessWidget {
  const StudentAttendanceRecords({super.key, required this.history});

  final AttendanceHistory history;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<AttendanceHistoryRecord>>{};
    for (final record in history.records) {
      groups.putIfAbsent(record.date, () => []).add(record);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.sm,
        AubSpacing.margin,
        AubSpacing.xl,
      ),
      children: [
        if (history.summary.marked > 0) ...[
          _SummaryGrid(summary: history.summary),
          const SizedBox(height: AubSpacing.md),
        ],
        AubSectionTitle(title: AppStrings.attendanceHistory),
        const SizedBox(height: AubSpacing.sm),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 6),
            child: Row(
              children: [
                Text(
                  italianWeekdayDateYear(parseDateOnly(entry.key)),
                  style: AubText.headlineSm.copyWith(color: AubColors.textSecondary),
                ),
                const SizedBox(width: 8),
                const Expanded(child: Divider(color: AubColors.borderMuted)),
              ],
            ),
          ),
          for (final record in entry.value)
            Padding(
              padding: const EdgeInsets.only(bottom: AubSpacing.sm),
              child: _RecordCard(record: record),
            ),
        ],
      ],
    );
  }
}

class _MonthBar extends StatelessWidget {
  const _MonthBar({required this.month, required this.controller});

  final String month;
  final AttendanceHistoryController controller;

  @override
  Widget build(BuildContext context) {
    final date = DateTime(
      int.parse(month.split('-')[0]),
      int.parse(month.split('-')[1]),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AubSpacing.margin,
        AubSpacing.sm,
        AubSpacing.margin,
        AubSpacing.sm,
      ),
      child: AubCard(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: controller.loadPrevious,
                  icon: const Icon(Icons.chevron_left),
                ),
                const Icon(Icons.calendar_month, size: 18, color: AubColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    italianMonthYear(date),
                    style: AubText.headlineSm,
                  ),
                ),
                IconButton(
                  onPressed: controller.loadNext,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: controller.loadCurrent,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: const Text(AppStrings.thisMonth),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary});

  final AttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AubSpacing.md),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: AppStrings.totalLessons,
                  value: summary.marked,
                  color: AubColors.textPrimary,
                  icon: Icons.school_outlined,
                ),
              ),
              const SizedBox(width: AubSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: AppStrings.presentPlural,
                  value: summary.present,
                  color: AubColors.success,
                  icon: Icons.check_circle,
                  iconBg: AubColors.successBg,
                ),
              ),
            ],
          ),
          const SizedBox(height: AubSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  label: AppStrings.absentPlural,
                  value: summary.absent,
                  color: AubColors.alert,
                  icon: Icons.cancel,
                  iconBg: AubColors.alertBg,
                ),
              ),
              const SizedBox(width: AubSpacing.sm),
              Expanded(
                child: _StatCard(
                  label: AppStrings.excusedPlural,
                  value: summary.excused,
                  color: AubColors.warning,
                  icon: Icons.verified,
                  iconBg: AubColors.warningBg,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.iconBg,
  });

  final String label;
  final int value;
  final Color color;
  final IconData icon;
  final Color? iconBg;

  @override
  Widget build(BuildContext context) {
    return AubCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: AubText.labelCaps.copyWith(color: color),
                ),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg ?? AubColors.surfaceSubtle,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('$value', style: AubText.headlineXl.copyWith(color: color, height: 1)),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record});

  final AttendanceHistoryRecord record;

  @override
  Widget build(BuildContext context) {
    final (label, tone, icon, strip) = switch (record.status) {
      AttendanceStatus.present => (
          AppStrings.present,
          AubBadgeTone.success,
          Icons.check_circle,
          AubColors.success,
        ),
      AttendanceStatus.absent => (
          AppStrings.absent,
          AubBadgeTone.alert,
          Icons.error,
          AubColors.alert,
        ),
      AttendanceStatus.excused => (
          AppStrings.excused,
          AubBadgeTone.warning,
          Icons.verified,
          AubColors.warning,
        ),
    };
    final room = record.location?.room?.name;
    final teacher = record.teacher?.displayName;

    return AubCard(
      stripColor: strip,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.title.toUpperCase(),
                      style: AubText.headlineMd,
                    ),
                    if (teacher != null && teacher.isNotEmpty)
                      Text(teacher, style: AubText.bodySm),
                  ],
                ),
              ),
              AubStatusBadge(label: label, tone: tone, icon: icon),
            ],
          ),
          const SizedBox(height: AubSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AubColors.surfaceSubtle.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(AubRadii.lg),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AubColors.gold),
                const SizedBox(width: 6),
                Text(
                  '${record.startsAt} — ${record.endsAt}',
                  style: AubText.bodySm,
                ),
                const Spacer(),
                if (room != null && room.isNotEmpty) ...[
                  const Icon(
                    Icons.meeting_room_outlined,
                    size: 16,
                    color: AubColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      room,
                      overflow: TextOverflow.ellipsis,
                      style: AubText.bodySm,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
