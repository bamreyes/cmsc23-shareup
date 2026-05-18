import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/constants/colors.dart';
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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final distanceText = widget.distance != null
        ? '${widget.distance!.toStringAsFixed(1)} km away'
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => context.push(
              '/item-details',
              extra: {
                'post': widget.post,
                'user': _postUser,
                'distance': distanceText,
              },
            ),
            splashColor: Colors.white.withValues(alpha: 0.15),
            highlightColor: Colors.white.withValues(alpha: 0.08),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                // 1. Background image
                AspectRatio(
                  aspectRatio: 1.05,
                  child: Image.network(
                    widget.post.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.0),
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildPostHeader(distanceText),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildPostDetailsOverlay(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(String? distanceText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage(_postUser!.profileImage),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "@${_postUser!.username}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.neutral0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  "${timeAgo(widget.post.createdAt)} · $distanceText",
                  style: const TextStyle(
                    color: AppColors.neutral200,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetailsOverlay() {
    final isNew = DateTime.now().difference(widget.post.createdAt).inHours < 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.0),
            Colors.black.withValues(alpha: 0.40),
            Colors.black.withValues(alpha: 0.85),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  widget.post.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black45,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isNew) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1.5,
                  ),
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary500,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Text(
                    "NEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),

          GestureDetector(
            onTap: () {},
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  ExpirationTag(expirationDate: widget.post.expirationDate),
                  if (widget.post.dietaryTags.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    ...widget.post.dietaryTags.map((tag) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Tag(label: tag, isFilled: true),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Item Description
          Text(
            widget.post.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.3,
              shadows: const [
                Shadow(
                  color: Colors.black38,
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
