import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/exchanges/widgets/inbound_request_card.dart';

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
        context.read<ExchangeProvider>().fetchInboundRequestforPost(widget.post.id!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final exchangeProvider = context.watch<ExchangeProvider>();
    final requests = exchangeProvider.getInboundRequestsForPost(widget.post.id ?? '');

    final livePost = exchangeProvider.posts.firstWhere(
      (p) => p.id == widget.post.id,
      orElse: () => widget.post,
    );

    if (exchangeProvider.isLoading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (livePost.status == PostStatus.reserved || livePost.status == PostStatus.completed) {
      final message = livePost.status == PostStatus.completed
          ? "This exchange has been completed."
          : "This item is already reserved.";
      
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
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
          final requesterProfile = exchangeProvider.getCachedRequester(request.requesterId);

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