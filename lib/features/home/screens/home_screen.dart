import 'package:flutter/material.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().loadCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().currentUser;

    return Scaffold(
      appBar: AppHeader.greeting(
        name: user?.firstName ?? 'User',
        avatarUrl: user?.profileImage,
      ),
      body: const Center(
        child: Text(
          'Home',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
