import 'package:flutter/material.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/widgets/buttons/secondary_button.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/auth/providers/auth_provider.dart';
import 'package:project/features/profile/widgets/dietary_preferences.dart';
import 'package:project/features/profile/widgets/discovery_radius_slider.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/features/profile/widgets/theme_preferences.dart';
import 'package:provider/provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<String>? _tempTags;
  double? _tempRadius;
  AppMode? _tempMode;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>();
    final user = profile.currentUser;

    return Scaffold(
      appBar: AppHeader.title(title: 'Profile'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            DietaryPreferences(
              initialTags: user?.dietaryTags,
              onChanged: (tags) {
                setState(() {
                  _tempTags = tags;
                });
              },
            ),
            SizedBox(height: 32),
            DiscoveryRadiusSlider(
              initialRadius: user?.discoveryRadius,
              onChanged: (radius) {
                setState(() {
                  _tempRadius = radius;
                });
              },
            ),
            SizedBox(height: 32),
            ThemePreferences(
              onChanged: (mode) {
                setState(() {
                  _tempMode = mode;
                });
              },
            ),
            SizedBox(height: 64),
            PrimaryButton(
              text: 'Save Profile',
              isLoading: _isSaving,
              onPressed: () async {
                setState(() {
                  _isSaving = true;
                });

                await profile.updateProfile(
                  dietaryTags: _tempTags,
                  discoveryRadius: _tempRadius,
                  appMode: _tempMode,
                );

                if (mounted) {
                  setState(() {
                    _isSaving = false;
                  });
                  // ignore: use_build_context_synchronously
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
            SecondaryButton(
              text: 'Log Out',
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.logOut();
              },
            ),
          ],
        ),
      ),
    );
  }
}
