import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/home/providers/home_provider.dart';
import 'package:project/features/home/widgets/quick_action_tile.dart';
import 'package:project/features/home/widgets/impact_banner.dart';
import 'package:project/features/home/widgets/leaderboard_section.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = context.read<ProfileProvider>();
      final result = await profile.loadCurrentUser();
      if (result.isSuccess && result.data != null && mounted) {
        context.read<HomeProvider>().fetchStats(result.data!.uid!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().currentUser;
    final home = context.watch<HomeProvider>();

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppHeader.greeting(
        name: user.firstName,
        avatarUrl: user.profileImage,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (home.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (home.error != null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Failed to load stats')),
              )
            else
              ImpactBanner(
                postCount: home.postCount,
                requestCount: home.requestCount,
              ),
            SizedBox(height: 4),
            _buildQuickActions(),
            SizedBox(height: 16),
            LeaderboardSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              QuickActionTile(
                label: 'Scan QR',
                icon: Icons.qr_code_scanner_rounded,
                onTap: () => context.push('/scan-qr'),
              ),
              SizedBox(width: 12),
              QuickActionTile(
                label: 'Add Post',
                icon: Icons.add_circle_outline_rounded,
                onTap: () => context.push('/add-item'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
