import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/exchanges/widgets/exchanges_post.dart';
import 'package:project/features/exchanges/widgets/exchanges_request.dart';
import 'package:project/features/profile/providers/profile_provider.dart';
import 'package:provider/provider.dart';

class ExchangesScreen extends StatefulWidget {
  const ExchangesScreen({super.key});

  @override
  State<ExchangesScreen> createState() => _ExchangesScreenState();
}

class _ExchangesScreenState extends State<ExchangesScreen> {
  ProfileProvider get profileProvider => context.read<ProfileProvider>();
  UserModel? get currentUser => profileProvider.currentUser;
  ExchangeProvider get exchangeProvider => context.read<ExchangeProvider>();
  List<PostModel> get posts => exchangeProvider.posts;
  List<RequestModel> get requests => exchangeProvider.requests;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (currentUser != null && currentUser!.uid != null) {
        exchangeProvider.fetchMyPosts(currentUser!.uid!);
        exchangeProvider.fetchMyRequests(currentUser!.uid!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ProfileProvider>();
    context.watch<ExchangeProvider>();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FloatingActionButton(
              onPressed: () {},
              child: Icon(Icons.qr_code_scanner),
            ),
            FloatingActionButton(onPressed: () {}, child: Icon(Icons.add)),
          ],
        ),
        appBar: AppHeader.title(
          title: 'Exchanges',
          bottom: TabBar(
            indicatorColor: AppColors.primary500,
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 3,
            labelColor: AppColors.primary500,
            unselectedLabelColor: AppColors.neutral500,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: [
              Tab(text: "My Posts"),
              Tab(text: "My Requests"),
            ],
          ),
        ),
        body: currentUser == null
            ? Center(child: CircularProgressIndicator())
            : TabBarView(children: [_buildPosts(), _buildRequests()]),
      ),
    );
  }

  Widget _buildPosts() {
    if (exchangeProvider.isLoading && posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await exchangeProvider.fetchMyPosts(currentUser!.uid!);
      },
      child: posts.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(child: Text("You haven't posted anything yet.")),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: posts.length,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 12),
              itemBuilder: (context, index) {
                return ExchangesPost(post: posts[index], user: currentUser!);
              },
            ),
    );
  }

  Widget _buildRequests() {
    if (exchangeProvider.isLoading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () async {
        await exchangeProvider.fetchMyRequests(currentUser!.uid!);
      },
      child: requests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                const Center(
                  child: Text("You haven't requested anything yet."),
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: requests.length,
              separatorBuilder: (BuildContext context, int index) =>
                  SizedBox(height: 12),
              itemBuilder: (context, index) {
                final request = requests[index];
                final details = exchangeProvider.requestDetails[request.postId];

                if (details == null) {
                  return const SizedBox();
                }

                return ExchangesRequest(
                  request: request,
                  post: details['post'] as PostModel,
                  postOwner: details['owner'] as UserModel,
                );
              },
            ),
    );
  }
}
