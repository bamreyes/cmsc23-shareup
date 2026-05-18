import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/exchanges/widgets/inbound_request_card.dart';
import 'package:project/features/exchanges/widgets/pickup_pass_card.dart';
import 'package:project/core/widgets/common/loading_screen.dart';
import 'package:project/features/profile/providers/profile_provider.dart';

class ItemRequest extends StatefulWidget {
  final PostModel post;

  const ItemRequest({super.key, required this.post});

  @override
  State<ItemRequest> createState() => _ItemRequestState();
}

class _ItemRequestState extends State<ItemRequest> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.post.id != null && mounted) {
        context.read<ExchangeProvider>().fetchInboundRequestforPost(
          widget.post.id!,
        );
        context.read<ExchangeProvider>().fetchReceiverForPost(widget.post);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeProvider = context.watch<ExchangeProvider>();
    final requests = exchangeProvider.getInboundRequestsForPost(
      widget.post.id ?? '',
    );

    final livePost = exchangeProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    if (exchangeProvider.isLoading && requests.isEmpty) {
      return const LoadingScreen(
        title: 'Loading details',
        subtitle: 'Updating exchange information...',
      );
    }

    if (livePost.status == PostStatus.reserved ||
        livePost.status == PostStatus.completed) {
      final receiver = exchangeProvider.getReceiverForPost(livePost.id ?? '');
      final request = exchangeProvider.getRequestForPost(livePost.id ?? '');

      if (receiver == null || request == null) {
        return const LoadingScreen(
          title: 'Loading details',
          subtitle: 'Updating exchange information...',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          final profileProvider = context.read<ProfileProvider>();
          if (profileProvider.userId != null) {
            await exchangeProvider.fetchMyPosts(profileProvider.userId!);
          }
          if (livePost.id != null) {
            await exchangeProvider.fetchInboundRequestforPost(livePost.id!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: PickupPassCard(
            post: livePost,
            receiver: receiver,
            request: request,
          ),
        ),
      );
    }

    if (requests.isEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          if (widget.post.id != null) {
            await exchangeProvider.fetchInboundRequestforPost(widget.post.id!);
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            const Center(
              child: Text(
                "No incoming requests for this item.",
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        if (widget.post.id != null) {
          await exchangeProvider.fetchInboundRequestforPost(widget.post.id!);
        }
      },
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: requests.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final request = requests[index];
          final requesterProfile = exchangeProvider.getCachedRequester(
            request.requesterId,
          );

          return InboundRequestCard(
            request: request,
            requester: requesterProfile,
            postId: widget.post.id!,
          );
        },
      ),
    );
  }
}
