import 'package:flutter/material.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/features/profile/widgets/dietary_preferences.dart';
import 'package:project/features/profile/widgets/discovery_radius_slider.dart';
import 'package:project/features/profile/widgets/notification_settings.dart';
import 'package:project/core/models/notification_preferences.dart';
import 'package:project/features/profile/widgets/theme_preferences.dart';
import 'package:project/features/profile/widgets/profile_header.dart';
import 'package:provider/provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _saveField({
    List<String>? dietaryTags,
    double? discoveryRadius,
    AppMode? appMode,
    NotificationPreferences? notificationPreferences,
  }) {
    context.read<ProfileProvider>().updateProfile(
      dietaryTags: dietaryTags,
      discoveryRadius: discoveryRadius,
      appMode: appMode,
      notificationPreferences: notificationPreferences,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final user = profile.currentUser;

    return Scaffold(
      appBar: AppHeader.title(title: 'Profile'),
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(user: user),
            SizedBox(height: 24),
            DiscoveryRadiusSlider(
              initialRadius: user?.discoveryRadius,
              onChangeEnd: (radius) {
                _saveField(discoveryRadius: radius);
              },
            ),
            SizedBox(height: 12),
            DietaryPreferences(
              initialTags: user?.dietaryTags,
              onChanged: (tags) {
                _saveField(dietaryTags: tags);
              },
            ),
            if (user != null) ...[
              SizedBox(height: 12),
              NotificationSettings(
                notifications: user.notificationPreferences,
                onChanged: (prefs) {
                  _saveField(notificationPreferences: prefs);
                },
              ),
            ],
            SizedBox(height: 12),
            ThemePreferences(
              onChanged: (mode) {
                _saveField(appMode: mode);
              },
            ),

            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  final authProvider = context.read<AuthProvider>();
                  authProvider.logOut();
                },
                icon: Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: AppColors.error500,
                ),
                label: Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppColors.error500,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
