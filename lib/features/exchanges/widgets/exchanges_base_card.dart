import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/utils/time_ago.dart';
import 'package:project/core/widgets/common/tag.dart';

class ExchangesBaseCard extends StatelessWidget {
  final UserModel user;
  final DateTime createdAt;
  final PostModel post;
  final Widget headerTag;
  final Widget pickupDetails;
  final Widget alert;
  final VoidCallback? onTap;

  const ExchangesBaseCard({
    super.key,
    required this.user,
    required this.createdAt,
    required this.post,
    required this.headerTag,
    required this.pickupDetails,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? AppColors.neutral900 : colorScheme.surface;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.neutral200;
    final dividerColor = isDark ? AppColors.neutral800 : AppColors.neutral100;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: cardBgColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildPostHeader(),
              Divider(color: dividerColor, height: 24),
              _buildPostMainDetails(context),
              Divider(color: dividerColor, height: 24),
              pickupDetails,
              SizedBox(height: 12),
              alert,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(user.profileImage),
        ),
        SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "@${user.username}",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Row(
              children: [
                Icon(Icons.access_time, size: 12, color: AppColors.neutral400),
                SizedBox(width: 3),
                Text(
                  timeAgo(createdAt),
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        Spacer(),
        headerTag,
      ],
    );
  }

  Widget _buildPostMainDetails(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              post.image,
              width: 140,
              height: 140,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 120,
                height: 120,
                color: colorScheme.surfaceContainerLow,
                child: Icon(
                  Icons.broken_image,
                  size: 32,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Wrap(
                  spacing: 4,
                  runSpacing: 6,
                  children: post.dietaryTags
                      .map((tag) => Tag(label: tag))
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
