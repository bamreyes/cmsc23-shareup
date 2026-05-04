import 'package:flutter/material.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/widgets/common/tag.dart';

class ItemImageSection extends StatelessWidget {
  final PostModel post;

  ItemImageSection({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            post.image,
            width: double.infinity,
            height: 380,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 380,
              color: colorScheme.surfaceContainerLow,
              child: Icon(
                Icons.broken_image,
                size: 50,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: post.dietaryTags
                    .map((tag) => Tag(label: tag))
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
