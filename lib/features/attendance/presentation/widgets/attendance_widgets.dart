import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';
import 'package:aub/shared/widgets/aub_avatar.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class AttendanceStudentRow extends StatelessWidget {
  const AttendanceStudentRow({
    super.key,
    required this.student,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final AttendanceStudent student;
  final AttendanceStatus? selected;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AubSpacing.sm),
      child: AubCard(
        padding: const EdgeInsets.all(AubSpacing.sm),
        color: enabled ? AubColors.surfaceCard : AubColors.surfaceContainerLow,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AubAvatar(
                  size: 40,
                  photoUrl: student.photoUrl,
                  name: student.displayName,
                ),
                const SizedBox(width: AubSpacing.sm),
                Expanded(
                  child: Text(
                    student.displayName,
                    style: AubText.labelMd,
                  ),
                ),
                if (selected == null)
                  Text(
                    AppStrings.unmarked,
                    style: AubText.labelSm.copyWith(color: AubColors.textMuted),
                  ),
              ],
            ),
            const SizedBox(height: AubSpacing.sm),
            AttendanceStatusSelector(
              selected: selected,
              enabled: enabled,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class AttendanceStatusSelector extends StatelessWidget {
  const AttendanceStatusSelector({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onChanged,
  });

  final AttendanceStatus? selected;
  final bool enabled;
  final ValueChanged<AttendanceStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _StatusChip(
              label: AppStrings.present,
              selected: selected == AttendanceStatus.present,
              enabled: enabled,
              selectedColor: AubColors.success,
              onTap: () => onChanged(AttendanceStatus.present),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _StatusChip(
              label: AppStrings.absent,
              selected: selected == AttendanceStatus.absent,
              enabled: enabled,
              selectedColor: AubColors.alert,
              onTap: () => onChanged(AttendanceStatus.absent),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: _StatusChip(
              label: AppStrings.excused,
              selected: selected == AttendanceStatus.excused,
              enabled: enabled,
              selectedColor: AubColors.warning,
              onTap: () => onChanged(AttendanceStatus.excused),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      selectedColor: selectedColor.withValues(alpha: 0.16),
      labelStyle: AubText.labelSm.copyWith(
        color: selected ? selectedColor : AubColors.textSecondary,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? selectedColor : AubColors.borderMuted,
      ),
      onSelected: enabled ? (_) => onTap() : null,
    );
  }
}

class AttendanceHeader extends StatelessWidget {
  const AttendanceHeader({super.key, required this.lesson, this.readOnly = false});

  final AttendanceLesson lesson;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final className = lesson.academyClass?.name;
    final room = lesson.location?.room?.name;
    final building = lesson.location?.building?.name;

    return AubCard(
      stripColor: readOnly ? AubColors.alert : AubColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (className != null && className.isNotEmpty)
            Text(className, style: AubText.labelCaps),
          Text(lesson.title, style: AubText.headlineMd),
          const SizedBox(height: 6),
          Text('${lesson.startsAt} – ${lesson.endsAt}', style: AubText.bodySm),
          if (room != null && room.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(room, style: AubText.bodySm),
          ],
          if (building != null && building.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(building, style: AubText.bodySm),
          ],
          if (readOnly) ...[
            const SizedBox(height: 8),
            Text(
              AppStrings.lessonCancelled,
              style: AubText.labelMd.copyWith(color: AubColors.alert),
            ),
          ],
        ],
      ),
    );
  }
}

Future<bool> confirmDiscardAttendance(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        content: const Text(AppStrings.unsavedAttendance),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.leaveWithoutSaving),
          ),
        ],
      );
    },
  );
  return result ?? false;
}

class AttendanceSaveBar extends StatelessWidget {
  const AttendanceSaveBar({
    super.key,
    required this.controller,
  });

  final AttendanceController controller;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return FilledButton(
          onPressed: controller.canSave ? controller.save : null,
          child: controller.state.saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(AppStrings.saveAttendance),
        );
      },
    );
  }
}
