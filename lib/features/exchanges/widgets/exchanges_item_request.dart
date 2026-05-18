import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/features/exchanges/widgets/inbound_request_card.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';

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
        context.read<ExchangeProvider>().fetchReceiverForPost(widget.post);
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
      if (livePost.status == PostStatus.completed) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "This exchange has been completed.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        );
      }
      final receiver = exchangeProvider.getReceiverForPost(livePost.id ?? '');
      final request = exchangeProvider.getRequestForPost(livePost.id ?? '');


      if (receiver == null || request == null) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: _buildPickupPassCard(context, livePost, receiver, request),
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

  Widget _buildPickupPassCard(BuildContext context, PostModel post, UserModel receiver, RequestModel request) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppColors.neutral800 : AppColors.neutral200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  "Pickup Pass",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black),
            ),
            child: QrImageView(
              data: 'shareup:${post.id}',
              version: QrVersions.auto,
              size: 160.0,
              gapless: false,
              eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
              dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Colors.black),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Scan to verify transaction",
            style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),
          Row(
            children: List.generate(
              32,
              (index) => Expanded(
                child: Container(
                  color: index % 2 == 0 ? Colors.transparent : (isDark ? AppColors.neutral700 : Colors.grey[300]),
                  height: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildPassRow(
            label: "Reserved for",
            value: receiver.username,
            avatarUrl: receiver.profileImage,
          ),
          const SizedBox(height: 16),

          _buildPassRow(
            icon: Icons.calendar_month_outlined,
            label: "Pickup Schedule",
            value: DateFormatter.formatDateTime(request.pickupDatetime),
            iconColor: const Color(0xFFFBC02D), 
            iconBgColor: const Color(0xFFFFF9C4), 
          ),
          const SizedBox(height: 16),

          _buildPassRow(
            icon: Icons.location_on_outlined,
            label: "Pickup Location",
            value: post.locationName,
            iconColor: const Color(0xFF42A5F5), 
            iconBgColor: const Color(0xFFE3F2FD), 
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary500, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                "Cancel Pickup",
                style: TextStyle(color: AppColors.primary500, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPassRow({required String label,
    required String value,
    IconData? icon,
    String? avatarUrl,
    Color? iconColor,
    Color? iconBgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

  Widget leadingWidget;
    if (avatarUrl != null) {
      leadingWidget = CircleAvatar(
        radius: 18,
        backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
        backgroundColor: isDark ? AppColors.neutral800 : Colors.grey[300],
        child: avatarUrl.isEmpty ? const Icon(Icons.person, size: 18, color: Colors.white) : null,
      );
    } else {
      leadingWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark ? (iconColor?.withOpacity(0.15) ?? Colors.transparent) : (iconBgColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: isDark ? (iconColor ?? Colors.grey[400]) : (iconColor ?? Colors.grey[500])),
      );
    }
    return Row(
      children: [
        leadingWidget,
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 14,
                  color: isDark ? AppColors.neutral100 : Colors.black87,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}