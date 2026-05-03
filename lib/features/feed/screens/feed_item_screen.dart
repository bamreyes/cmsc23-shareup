import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/user_model.dart';
import '../../../core/widgets/common/tag.dart';
import '../../../core/constants/colors.dart';
import '../../../core/models/post_model.dart';
import 'package:project/core/utils/time_ago.dart';
import 'package:project/core/widgets/headers/app_header.dart';

class FeedItemScreen extends StatelessWidget {
  final PostModel post;
  final UserModel? user;
  final String? distance;

  const FeedItemScreen({
    super.key,
    required this.post,
    this.user,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final expirationColor = AppColors.expiryColor(post.expirationDate);
    final bool isReserved = post.status == PostStatus.reserved;
    AppHeader.close(title: 'Item Details', onClose: () => context.pop());
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppHeader.close(
        title: 'Item Details',
        onClose: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundImage: user?.profileImage != null
                      ? NetworkImage(user!.profileImage)
                      : const NetworkImage('https://via.placeholder.com/150'),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.username ??
                          'User ${post.userId.substring(0, 5)}...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppColors.grey400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          timeAgo(post.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.grey600,
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 16),
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: AppColors.grey400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            distance!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.grey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                post.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 300,
                  color: AppColors.grey200,
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: AppColors.grey600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              post.name,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.dietaryTags.map((tag) => Tag(label: tag)).toList(),
            ),
            const SizedBox(height: 24),
            _buildDetailSection(theme, 'Product Description', post.description),
            _buildDetailSection(
              theme,
              'Best Before',
              '${post.expirationDate.month}/${post.expirationDate.day}/${post.expirationDate.year}',
              titleColor: expirationColor,
            ),
            _buildDetailSection(
              theme,
              'Pickup Location',
              '${post.locationName}\n${distance} from you',
            ),
            _buildDetailSection(
              theme,
              'Posting date',
              '${post.createdAt.month}/${post.createdAt.day}/${post.createdAt.year}',
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildBottomAction(context, theme, isReserved: isReserved),
        ),
      ),
    );
  }

  Widget _buildDetailSection(
    ThemeData theme,
    String title,
    String content, {
    Color? titleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: titleColor ?? AppColors.grey600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(
    BuildContext context,
    ThemeData theme, {
    required bool isReserved,
  }) {
    if (isReserved) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.warning50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.statusReserved,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Item already reserved',
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppColors.statusReserved,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          context.push('/request', extra: post);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Request Item',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      );
    }
  }
}
