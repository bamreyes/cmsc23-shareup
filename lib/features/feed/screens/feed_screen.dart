import 'package:flutter/material.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/feed/providers/feed_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/features/feed/widgets/feed_post.dart';
import 'package:project/core/services/location_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _locationService = LocationService();

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
    final user = profileProvider.currentUser;

    final radius = user?.discoveryRadius ?? 50.0;
    final userLat = user?.latitude ?? 0.0;
    final userLng = user?.longitude ?? 0.0;
    final userTags = user?.dietaryTags ?? [];

    final postsData =
        feedProvider.posts
            // map post returning the post and distance
            .map((post) {
              final distance =
                  _locationService
                      .getDistance(
                        startLatitude: userLat,
                        startLongitude: userLng,
                        endLatitude: post.latitude,
                        endLongitude: post.longitude,
                      )
                      .data ??
                  0.0;
              return (post: post, distance: distance);
            })
            .where((item) {
              if (item.post.userId == currentUid) {
                return false; // filter out your posts
              }
              if (item.distance > radius) {
                return false; // filter posts outside your distance
              }
              if (userTags
                      .isNotEmpty && // filter posts not containing your tags
                  !item.post.dietaryTags.any(userTags.contains)) {
                return false;
              }
              return true;
            })
            .toList()
          ..sort(
            (a, b) => a.distance.compareTo(b.distance),
          ); // sort based on distance

    if (feedProvider.isLoading && postsData.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppHeader.title(title: "Feed"),
      body: RefreshIndicator(
        onRefresh: () => feedProvider.fetchAllPosts(),
        child: postsData.isEmpty
            ? ListView(
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Text(
                      feedProvider.error != null
                          ? 'Error: ${feedProvider.error}'
                          : 'No posts found nearby with your preferences.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: postsData.length,
                itemBuilder: (context, index) {
                  final item = postsData[index];
                  return FeedPost(post: item.post, distance: item.distance);
                },
              ),
      ),
    );
  }
}
