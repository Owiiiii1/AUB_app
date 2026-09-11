import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:aub/app/app_strings.dart';
import 'package:aub/app/theme/aub_colors.dart';
import 'package:aub/app/theme/aub_spacing.dart';
import 'package:aub/app/theme/aub_typography.dart';
import 'package:aub/core/api/api_exception.dart';
import 'package:aub/features/profile/data/profile_api.dart';
import 'package:aub/features/profile/models/auth_device.dart';
import 'package:aub/shared/widgets/aub_card.dart';

class DevicesScreen extends StatefulWidget {
  const DevicesScreen({super.key, required this.api});

  final ProfileApi api;

  @override
  State<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<AuthDevice>? _devices;
  Object? _error;
  bool _loading = true;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final devices = await widget.api.devices();
      if (!mounted) {
        return;
      }
      setState(() {
        _devices = devices;
        _loading = false;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<void> _revoke(AuthDevice device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppStrings.revokeDeviceTitle),
          content: const Text(AppStrings.revokeDeviceBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(AppStrings.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(AppStrings.revokeDevice),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _busy = true);
    try {
      await widget.api.revokeDevice(device.id);
      await _load();
    } on ApiException {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _logoutAll() async {
    setState(() => _busy = true);
    try {
      await widget.api.logoutAll();
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } on ApiException {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AubColors.surfaceIvory,
      appBar: AppBar(title: const Text(AppStrings.devices)),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: TextButton(
          onPressed: _load,
          child: const Text(AppStrings.retry),
        ),
      );
    }
    final devices = _devices ?? const <AuthDevice>[];
    return ListView(
      padding: const EdgeInsets.all(AubSpacing.margin),
      children: [
        for (final device in devices) ...[
          AubCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(device.name, style: AubText.bodyMd),
                      if (device.current)
                        Text(AppStrings.thisDevice, style: AubText.labelSm),
                      if (device.lastUsedAt != null)
                        Text(
                          '${AppStrings.lastUsed}: ${_format(device.lastUsedAt!)}',
                          style: AubText.labelSm,
                        ),
                    ],
                  ),
                ),
                if (!device.current)
                  TextButton(
                    onPressed: _busy ? null : () => _revoke(device),
                    child: const Text(AppStrings.revokeDevice),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AubSpacing.sm),
        ],
        if (devices.where((device) => !device.current).isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: AubSpacing.md),
            child: Text(AppStrings.noOtherDevices, style: AubText.bodySm),
          ),
        FilledButton(
          onPressed: _busy ? null : _logoutAll,
          style: FilledButton.styleFrom(backgroundColor: AubColors.alert),
          child: const Text(AppStrings.logoutAllDevices),
        ),
      ],
    );
  }

  String _format(DateTime value) {
    return DateFormat('d MMM yyyy, HH:mm', 'it').format(value.toLocal());
  }
}
