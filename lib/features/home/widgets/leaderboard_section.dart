import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/features/home/providers/home_provider.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({super.key});

  Color _getRankColor(int rank, BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    if (rank == 1) return Color(0xFFFFD700);
    if (rank == 2) return Color.fromARGB(255, 161, 161, 161);
    if (rank == 3) return Color(0xFFCD7F32);
    return isDarkMode ? AppColors.neutral400 : AppColors.neutral500;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<ProfileProvider>().currentUser;
    final home = context.watch<HomeProvider>();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const SizedBox.shrink();
    }

    final isEmpty = home.leaderboard.isEmpty;
    final shouldExpand = home.leaderboard.length > 3 || isEmpty;

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context, isDarkMode),
          const SizedBox(height: 8),
          shouldExpand
              ? Expanded(
                  child: isEmpty
                      ? _buildEmptyState(isDarkMode)
                      : _buildLeaderboardList(context, home, isDarkMode),
                )
              : _buildLeaderboardList(context, home, isDarkMode),
        ],
      ),
    );

    if (shouldExpand) {
      return Expanded(child: content);
    } else {
      return content;
    }
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
        padding: const EdgeInsets.all(32),
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
    final showPodium = home.leaderboard.length >= 3;
    final listEntries = showPodium
        ? home.leaderboard.skip(3).toList()
        : home.leaderboard;

    final listWidget = ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: showPodium ? Radius.zero : const Radius.circular(16),
        topRight: showPodium ? Radius.zero : const Radius.circular(16),
        bottomLeft: const Radius.circular(16),
        bottomRight: const Radius.circular(16),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: !showPodium,
        physics: showPodium ? null : const NeverScrollableScrollPhysics(),
        itemCount: listEntries.length,
        itemBuilder: (context, index) {
          final entry = listEntries[index];
          return _buildLeaderboardItem(
            context,
            entry,
            showPodium ? index + 4 : index + 1,
            isDarkMode,
          );
        },
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? AppColors.neutral900 : AppColors.neutral50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? AppColors.neutral800 : AppColors.neutral200,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPodium) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: _buildPodium(context, home, isDarkMode),
            ),
            if (listEntries.isNotEmpty)
              Divider(
                height: 1,
                thickness: 1,
                color: isDarkMode ? AppColors.neutral800 : AppColors.neutral200,
              ),
          ],
          if (listEntries.isNotEmpty)
            showPodium ? Expanded(child: listWidget) : listWidget,
        ],
      ),
    );
  }

  Widget _buildPodium(
    BuildContext context,
    HomeProvider home,
    bool isDarkMode,
  ) {
    if (home.leaderboard.isEmpty) return const SizedBox.shrink();

    final first = home.leaderboard.isNotEmpty ? home.leaderboard[0] : null;
    final second = home.leaderboard.length >= 2 ? home.leaderboard[1] : null;
    final third = home.leaderboard.length >= 3 ? home.leaderboard[2] : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 2nd place
        Expanded(
          child: second != null
              ? _buildPodiumColumn(
                  context: context,
                  entry: second,
                  rank: 2,
                  avatarRadius: 28,
                  isDarkMode: isDarkMode,
                )
              : SizedBox.shrink(),
        ),

        // 1st place
        Expanded(
          child: first != null
              ? _buildPodiumColumn(
                  context: context,
                  entry: first,
                  rank: 1,
                  avatarRadius: 36,
                  isDarkMode: isDarkMode,
                )
              : SizedBox.shrink(),
        ),

        // 3rd place
        Expanded(
          child: third != null
              ? _buildPodiumColumn(
                  context: context,
                  entry: third,
                  rank: 3,
                  avatarRadius: 24,
                  isDarkMode: isDarkMode,
                )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPodiumColumn({
    required BuildContext context,
    required dynamic entry,
    required int rank,
    required double avatarRadius,
    required bool isDarkMode,
  }) {
    final user = entry.user;
    final count = entry.count;
    final Color rankColor = _getRankColor(rank, context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 2.5),
              ),
              child: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: AppColors.neutral700,
                backgroundImage: user.profileImage.isNotEmpty
                    ? NetworkImage(user.profileImage)
                    : null,
                child: user.profileImage.isEmpty
                    ? Text(
                        '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                        style: TextStyle(
                          fontSize: avatarRadius * 0.6,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary100,
                        ),
                      )
                    : null,
              ),
            ),

            Positioned(
              bottom: -8,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: rankColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$count ${count == 1 ? 'Share' : 'Shares'}',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 14),

        Text(
          '${user.firstName} ${user.lastName}',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.white : AppColors.neutral800,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          '@${user.username}',
          style: TextStyle(fontSize: 10, color: AppColors.neutral500),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
    final Color rankColor = _getRankColor(rank, context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                rank.toString(),
                style: TextStyle(fontWeight: FontWeight.bold, color: rankColor),
              ),
            ),
          ),
          SizedBox(width: 12),

          Container(
            padding: rank <= 3 ? EdgeInsets.all(1.5) : EdgeInsets.zero,
            decoration: rank <= 3
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 2),
                  )
                : null,
            child: CircleAvatar(
              radius: 20,
              backgroundColor: rank <= 3
                  ? AppColors.neutral700
                  : AppColors.primary100,
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
                        color: rank <= 3
                            ? AppColors.primary100
                            : AppColors.primary700,
                      ),
                    )
                  : null,
            ),
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
