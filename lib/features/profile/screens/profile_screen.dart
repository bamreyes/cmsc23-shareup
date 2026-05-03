import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppHeader.title(title: 'Profile'),
      body: Center(
        child: Text(
          'Profile',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
