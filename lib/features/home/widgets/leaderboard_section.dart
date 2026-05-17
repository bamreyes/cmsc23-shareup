import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/features/home/providers/home_provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key});

  Color _getRankColor(int rank, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (rank == 1) return Color(0xFFFFD700); // Gold
    if (rank == 2) return Color.fromARGB(255, 161, 161, 161); // Silver
    if (rank == 3) return Color(0xFFCD7F32); // Bronze
    return isDarkMode ? AppColors.neutral400 : AppColors.neutral500;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().currentUser;
    final home = context.watch<HomeProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return SizedBox.shrink();
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, isDarkMode),
            SizedBox(height: 8),
            Expanded(
              child: home.leaderboard.isEmpty
                  ? _buildEmptyState(isDarkMode)
                  : _buildLeaderboardList(context, home, isDarkMode),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDarkMode) {
    return Text(
      'Leaderboards',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? AppColors.white : AppColors.neutral800,
      ),
    );
  }

  Widget _buildEmptyState(bool isDarkMode) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No completed exchanges yet. Be the first to share!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDarkMode ? AppColors.neutral400 : AppColors.neutral600,
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    BuildContext context,
    HomeProvider home,
    bool isDarkMode,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.neutral900 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.neutral800 : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          padding: EdgeInsets.zero,
          itemCount: home.leaderboard.length,
          separatorBuilder: (context, index) => Divider(
            height: 1,
            thickness: 1,
            color: isDarkMode ? AppColors.neutral800 : AppColors.neutral200,
          ),
          itemBuilder: (context, index) {
            final entry = home.leaderboard[index];
            return _buildLeaderboardItem(context, entry, index + 1, isDarkMode);
          },
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(
    BuildContext context,
    dynamic entry,
    int rank,
    bool isDarkMode,
  ) {
    final entryUser = entry.user;
    final count = entry.count;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Rank Number Badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getRankColor(rank, context).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getRankColor(rank, context),
                ),
              ),
            ),
          ),
          SizedBox(width: 12),

          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary100,
            backgroundImage: entryUser.profileImage.isNotEmpty
                ? NetworkImage(entryUser.profileImage)
                : null,
            child: entryUser.profileImage.isEmpty
                ? Text(
                    '${entryUser.firstName[0]}${entryUser.lastName[0]}'
                        .toUpperCase(),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary700,
                    ),
                  )
                : null,
          ),
          SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entryUser.firstName} ${entryUser.lastName}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? AppColors.white : AppColors.neutral800,
                  ),
                ),
                Text(
                  '@${entryUser.username}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode
                        ? AppColors.neutral400
                        : AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isDarkMode ? AppColors.primary950 : AppColors.primary50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDarkMode ? AppColors.primary800 : AppColors.primary100,
              ),
            ),
            child: Text(
              '$count ${count == 1 ? 'Share' : 'Shares'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? AppColors.primary300 : AppColors.primary700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
