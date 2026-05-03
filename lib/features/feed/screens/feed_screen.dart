import 'package:flutter/material.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/feed/providers/feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/features/feed/widgets/feed_post.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedProvider>().fetchAllPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final feedProvider = context.watch<FeedProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final currentUid = profileProvider.userId;
    
    // Filter out user's own posts
    final posts = feedProvider.posts.where((post) => post.userId != currentUid).toList();

    if (feedProvider.isLoading && posts.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    debugPrint('Posts count: ${posts.length}');

    return Scaffold(
      appBar: AppHeader.title(title: "Feed"),
      body: RefreshIndicator(
        onRefresh: () => feedProvider.fetchAllPosts(),
        child: ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            return FeedPost(post: posts[index]);
          },
        ),
      ),
    );
  }
}
