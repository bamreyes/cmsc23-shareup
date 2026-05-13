import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/notification_preferences.dart';

class NotificationSettings extends StatefulWidget {
  final NotificationPreferences notifications;
  final Function(NotificationPreferences)? onChanged;

  const NotificationSettings({
    super.key,
    required this.notifications,
    this.onChanged,
  });

  @override
  State<NotificationSettings> createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  late NotificationPreferences _preferences;

  @override
  void initState() {
    super.initState();
    _preferences = widget.notifications;
  }

  @override
  void didUpdateWidget(covariant NotificationSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notifications != oldWidget.notifications) {
      _preferences = widget.notifications;
    }
  }

  void _toggle(NotificationPreferences updated) {
    setState(() => _preferences = updated);
    widget.onChanged?.call(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.grey200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notification Preferences',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildToggle(
                label: 'New Posts Nearby',
                value: _preferences.newPost,
                onChanged: (value) =>
                    _toggle(_preferences.copyWith(newPost: value)),
              ),
              _buildToggle(
                label: 'Request Received',
                value: _preferences.requestReceived,
                onChanged: (value) =>
                    _toggle(_preferences.copyWith(requestReceived: value)),
              ),
              _buildToggle(
                label: 'Request Accepted',
                value: _preferences.requestAccepted,
                onChanged: (value) =>
                    _toggle(_preferences.copyWith(requestAccepted: value)),
              ),
              _buildToggle(
                label: 'Request Rejected',
                value: _preferences.requestRejected,
                onChanged: (value) =>
                    _toggle(_preferences.copyWith(requestRejected: value)),
              ),
              _buildToggle(
                label: 'Pickup Reminder',
                value: _preferences.pickupReminder,
                onChanged: (value) =>
                    _toggle(_preferences.copyWith(pickupReminder: value)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildToggle({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        Transform.scale(
          scale: 0.8,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }
}
