import 'package:flutter/material.dart';
import 'package:project/core/utils/time_ago.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/constants/colors.dart';

class ItemHeader extends StatelessWidget {
  final PostModel post;
  final UserModel? user;
  final String? uploaderName;
  final String? distance;

  const ItemHeader({
    super.key,
    required this.post,
    this.user,
    this.uploaderName,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final greyColor = theme.brightness == Brightness.light
        ? AppColors.neutral400
        : AppColors.neutral300;
    final displayName = uploaderName ?? user?.username ?? 'User';

    final isDark = theme.brightness == Brightness.dark;
    final cardBgColor = isDark ? AppColors.neutral900 : colorScheme.surface;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.grey200;

    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: cardBgColor,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorScheme.surfaceContainerLow,
            backgroundImage: user?.profileImage != null
                ? NetworkImage(user!.profileImage)
                : null,
            child: user?.profileImage == null
                ? Icon(Icons.person, color: greyColor)
                : null,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: greyColor),
                    SizedBox(width: 4),
                    Text(
                      timeAgo(post.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: greyColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    if (distance != null) ...[
                      SizedBox(width: 12),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: greyColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        distance!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: greyColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
