import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:project/features/exchanges/widgets/exchange_request_status_tag.dart';
import 'package:project/features/exchanges/widgets/exchanges_base_card.dart';
import 'package:project/features/exchanges/widgets/exchange_detail_row.dart';
import 'package:go_router/go_router.dart';

class ExchangesRequest extends StatelessWidget {
  final RequestModel request;
  final PostModel post;
  final UserModel postOwner;

  const ExchangesRequest({
    super.key,
    required this.request,
    required this.post,
    required this.postOwner,
  });

  @override
  Widget build(BuildContext context) {
    return ExchangesBaseCard(
      user: postOwner,
      createdAt: request.createdAt,
      post: post,
      headerTag: ExchangeRequestStatusTag(status: request.status),
      pickupDetails: _buildPickupDetails(),
      alert: _buildAlert(context),
      onTap: () {
        context.push(
          '/request-details',
          extra: {'request': request, 'post': post, 'postOwner': postOwner},
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
            title: 'Date',
            detail: DateFormatter.formatDate(request.pickupDatetime),
          ),
          SizedBox(height: 10),
          _buildDetails(
            icon: Icons.access_time_rounded,
            title: 'Time',
            detail: DateFormatter.formatTime(request.pickupDatetime),
          ),
          SizedBox(height: 10),
          _buildDetails(
            icon: Icons.location_pin,
            title: 'Location',
            detail: post.locationName,
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

  Widget _buildAlert(BuildContext context) {
    if (request.status == RequestStatus.accepted) {
      final isDark = Theme.of(context).brightness == Brightness.dark;

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 8),
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.success500.withValues(alpha: 0.15)
              : AppColors.success50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.statusActive, size: 20),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                "Accepted. Scan the QR code at pickup.",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: AppColors.statusActive,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox();
  }
}
