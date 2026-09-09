import 'package:flutter/material.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/core/media/safe_https_url.dart';
import 'package:aub/features/attendance/models/attendance_models.dart';
import 'package:aub/features/attendance/state/attendance_controller.dart';

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
    final photoUrl = isSafeHttpsUrl(student.photoUrl) ? student.photoUrl : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage:
                    photoUrl == null ? null : NetworkImage(photoUrl),
                child: photoUrl == null
                    ? Text(
                        student.displayName.isEmpty
                            ? '?'
                            : student.displayName[0].toUpperCase(),
                      )
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  student.displayName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            children: [
              _StatusChip(
                label: AppStrings.present,
                selected: selected == AttendanceStatus.present,
                enabled: enabled,
                onTap: () => onChanged(AttendanceStatus.present),
              ),
              _StatusChip(
                label: AppStrings.absent,
                selected: selected == AttendanceStatus.absent,
                enabled: enabled,
                onTap: () => onChanged(AttendanceStatus.absent),
              ),
              _StatusChip(
                label: AppStrings.excused,
                selected: selected == AttendanceStatus.excused,
                enabled: enabled,
                onTap: () => onChanged(AttendanceStatus.excused),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lesson.title, style: Theme.of(context).textTheme.titleLarge),
        if (className != null && className.isNotEmpty)
          Text(className, style: Theme.of(context).textTheme.titleMedium),
        Text('${lesson.startsAt} – ${lesson.endsAt}'),
        if (room != null && room.isNotEmpty) Text(room),
        if (readOnly) ...[
          const SizedBox(height: 8),
          const _CancelledBadge(),
        ],
      ],
    );
  }
}

class _CancelledBadge extends StatelessWidget {
  const _CancelledBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).disabledColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        AppStrings.lessonCancelled,
        style: Theme.of(context).textTheme.labelSmall,
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
