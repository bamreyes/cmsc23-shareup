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

    if (exchangeProvider.isLoading && requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (widget.post.status == PostStatus.reserved || widget.post.status == PostStatus.completed) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text("This item is already reserved.",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    if (requests.isEmpty) {
      return const Center(
        child: Text("No incoming requests for this item.",
        style: TextStyle(color: Colors.grey, fontSize: 15)
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
      )
    );
  }
}