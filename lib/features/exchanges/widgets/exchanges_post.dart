import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:provider/provider.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:project/features/exchanges/widgets/exchange_post_status_tag.dart';
import 'package:project/features/exchanges/widgets/exchanges_base_card.dart';
import 'package:project/features/exchanges/widgets/exchange_detail_row.dart';
import 'package:go_router/go_router.dart';

class ExchangesPost extends StatefulWidget {
  final PostModel post;
  final UserModel user;
  const ExchangesPost({super.key, required this.post, required this.user});

  @override
  State<ExchangesPost> createState() => _ExchangesPostState();
}

class _ExchangesPostState extends State<ExchangesPost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ExchangeProvider>().fetchReceiverForPost(widget.post);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ExchangesBaseCard(
      user: widget.user,
      createdAt: widget.post.createdAt,
      post: widget.post,
      headerTag: ExchangePostStatusTag(status: widget.post.status),
      pickupDetails: _buildPickupDetails(),
      alert: _buildAlert(),
      onTap: () {
        context.push(
          '/item',
          extra: {'post': widget.post, 'user': widget.user},
        );
      },
    );
  }

  Widget _buildPickupDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pickup Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.neutral400,
            ),
          ),
          SizedBox(height: 12),
          _buildDetails(
            icon: Icons.calendar_month_rounded,
            title: 'Best Before',
            detail: DateFormatter.formatDate(widget.post.expirationDate),
          ),
          SizedBox(height: 10),
          _buildDetails(
            icon: Icons.location_pin,
            title: 'Location',
            detail: widget.post.locationName,
          ),
        ],
      ),
    );
  }

  Widget _buildDetails({
    required IconData icon,
    required String title,
    required String detail,
  }) {
    return ExchangeDetailRow(icon: icon, title: title, detail: detail);
  }

  Widget _buildAlert() {
    if (widget.post.status == PostStatus.reserved) {
      final exchangeProvider = context.watch<ExchangeProvider>();
      final receiver = exchangeProvider.getReceiverForPost(
        widget.post.id ?? '',
      );
      final request = exchangeProvider.getRequestForPost(widget.post.id ?? '');
      final isDark = Theme.of(context).brightness == Brightness.dark;

      if (receiver == null) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.warning500.withValues(alpha: 0.15)
              : AppColors.warning50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.warning500,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(receiver.profileImage),
              ),
            ),

            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${receiver.username} ${(request != null && request.status == RequestStatus.accepted) ? 'reserved' : 'requested'} this item",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: isDark ? AppColors.warning500 : AppColors.warning900,
                  ),
                ),
                if (request != null) ...[
                  SizedBox(height: 2),
                  Text(
                    "Pickup at ${DateFormatter.formatDateTime(request.pickupDatetime)}",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppColors.warning500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
}
