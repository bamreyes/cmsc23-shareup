import 'package:flutter/material.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ThemePreferences extends StatelessWidget {
  final Function(AppMode)? onChanged;

  const ThemePreferences({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final mode =
        context.watch<ProfileProvider>().currentUser?.appMode ?? AppMode.system;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Theme Preference',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 16),
        DropdownButton<AppMode>(
          value: mode,
          isExpanded: true,
          underline: Container(
            height: 2,
            color: Theme.of(context).primaryColor,
          ),
          onChanged: (AppMode? newValue) {
            if (newValue != null) {
              onChanged?.call(newValue);
            }
          },
          items: AppMode.values.map<DropdownMenuItem<AppMode>>((AppMode value) {
            return DropdownMenuItem<AppMode>(
              value: value,
              child: Text(
                value.name[0].toUpperCase() +
                    value.name.substring(1).toLowerCase(),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
