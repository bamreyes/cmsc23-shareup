import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ThemePreferences extends StatefulWidget {
  final Function(AppMode)? onChanged;

  const ThemePreferences({super.key, this.onChanged});

  @override
  State<ThemePreferences> createState() => _ThemePreferencesState();
}

class _ThemePreferencesState extends State<ThemePreferences> {
  AppMode? _localMode;

  @override
  void initState() {
    super.initState();
    _localMode = context.read<ProfileProvider>().currentUser?.appMode;
  }

  @override
  Widget build(BuildContext context) {
    final providerMode =
        context.watch<ProfileProvider>().currentUser?.appMode ?? AppMode.system;
    final displayMode = _localMode ?? providerMode;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    IconData getIcon(AppMode mode) {
      switch (mode) {
        case AppMode.light:
          return Icons.light_mode_outlined;
        case AppMode.dark:
          return Icons.dark_mode_outlined;
        case AppMode.system:
          return Icons.settings_suggest_outlined;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Preference',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AppMode>(
              value: displayMode,
              isExpanded: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral400),
              borderRadius: BorderRadius.circular(16),
              onChanged: (AppMode? newValue) {
                if (newValue != null) {
                  setState(() {
                    _localMode = newValue;
                  });
                  widget.onChanged?.call(newValue);
                }
              },
              items: AppMode.values.map<DropdownMenuItem<AppMode>>((AppMode value) {
                return DropdownMenuItem<AppMode>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(getIcon(value), size: 20, color: AppColors.primary500),
                      SizedBox(width: 12),
                      Text(
                        value.name[0].toUpperCase() +
                            value.name.substring(1).toLowerCase(),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
