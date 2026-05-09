import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/utils/time_ago.dart';
import 'package:project/core/widgets/common/tag.dart';
import 'package:project/features/feed/widgets/expiration_tag.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/services/database_service.dart';

class FeedPost extends StatefulWidget {
  final PostModel post;
  final double? distance;
  const FeedPost({super.key, required this.post, this.distance});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  final _database = DatabaseService();
  UserModel? _postUser;

  @override
  void initState() {
    super.initState();
    _database.getUserById(widget.post.userId).then((result) {
      if (result.isSuccess && mounted) {
        setState(() => _postUser = result.data!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_postUser == null) {
      return const SizedBox.shrink();
    }

    final distanceText = widget.distance != null
        ? '${widget.distance!.toStringAsFixed(1)} km away'
        : null;

    return InkWell(
      onTap: () => context.push(
        '/item-details',
        extra: {
          'post': widget.post,
          'user': _postUser,
          'distance': distanceText,
        },
      ),
      child: Column(
        children: [
          _buildPostHeader(distanceText),
          _buildPostImage(),
          _buildPostDetails(),
        ],
      ),
    );
  }

  Widget _buildPostHeader(String? distanceText) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(_postUser!.profileImage),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _postUser!.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  timeAgo(widget.post.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                if (distanceText != null) ...[
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 14, color: Colors.grey[400]),
                  const SizedBox(width: 4),
                  Text(
                    distanceText,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPostImage() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 1.0,
          child: Image.network(
            widget.post.image,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: ExpirationTag(expirationDate: widget.post.expirationDate),
        ),
      ],
    );
  }

  Widget _buildPostDetails() {
    return Column(
      children: [
        Text(widget.post.name),
        Text(widget.post.description),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: widget.post.dietaryTags
              .map((tag) => Tag(label: tag))
              .toList(),
        ),
      ],
    );
  }
}
