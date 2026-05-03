import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart'; 
import '../../../core/models/post_model.dart'; 

class FeedItemScreen extends StatelessWidget {
  final PostModel post;

  const FeedItemScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final expirationColor = AppColors.expiryColor(post.expirationDate); 
        final bool isReserved = post.status == PostStatus.reserved;

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.black),
          onPressed: () => context.pop(), 
        ),
        title: Text(
          'Item Details',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Using placeholders for the UI build for now
            Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), 
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User ${post.userId.substring(0, 5)}...', // Placeholder Name
                      style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '5 hours ago • 1.2 km away', // Placeholder distance 
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey600),
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
                  child: const Icon(Icons.broken_image, size: 50, color: AppColors.grey600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              post.name,
              style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: post.dietaryTags.map((tag) => _buildTag(tag, theme)).toList(),
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
              '${post.locationName}\n1.2 km away from you',
            ),
            _buildDetailSection(
              theme, 
              'Posting date', 
              '${post.createdAt.month}/${post.createdAt.day}/${post.createdAt.year}' 
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

  Widget _buildTag(String label, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderLight),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: AppColors.black),
      ),
    );
  }

  Widget _buildDetailSection(ThemeData theme, String title, String content, {Color? titleColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(color: titleColor ?? AppColors.grey600),
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

  Widget _buildBottomAction(BuildContext context, ThemeData theme, {required bool isReserved}) {
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
            const Icon(Icons.info_outline, color: AppColors.statusReserved, size: 20),
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