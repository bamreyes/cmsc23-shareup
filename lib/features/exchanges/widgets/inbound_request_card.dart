import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:project/core/utils/time_ago.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/core/widgets/buttons/secondary_button.dart';

class InboundRequestCard extends StatelessWidget {
  final RequestModel request;
  final UserModel? requester;
  final String postId;

  const InboundRequestCard({super.key, required this.request, required this.requester, required this.postId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBgColor = isDark ? AppColors.neutral900 : Colors.white;
    final msgBgColor = isDark ? AppColors.neutral800 : AppColors.neutral100;
    final borderColor = isDark ? AppColors.neutral800 : AppColors.neutral200;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primary300,
                backgroundImage: requester?.profileImage != null && requester!.profileImage.isNotEmpty
                    ? NetworkImage(requester!.profileImage)
                    : null,
                child: requester?.profileImage == null || requester!.profileImage.isEmpty
                    ? const Icon(Icons.person, color: Colors.white, size: 20)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      requester?.username ?? "User Request",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo(request.createdAt),
                      style: const TextStyle(
                        color: AppColors.neutral400, 
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: msgBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              (request.message != null && request.message!.isNotEmpty)
                  ? request.message!
                  : "No written message provided.",
              style: TextStyle(
                color: (request.message != null && request.message!.isNotEmpty)
                    ? theme.colorScheme.onSurface
                    : AppColors.neutral400,
                fontSize: 14,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(
                Icons.calendar_today_rounded, 
                size: 16, 
                color: AppColors.primary500,
              ),
              const SizedBox(width: 8),
              Text(
                "Pickup at ${DateFormatter.formatDateTime(request.pickupDatetime)}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 13,
                  color: AppColors.neutral700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  text: "Reject",
                  height: 44, 
                  onPressed: () => _onRejectPressed(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: PrimaryButton(
                  text: "Accept",
                  height: 44,
                  onPressed: () => _onAcceptPressed(context),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _onAcceptPressed(BuildContext context) async {
    final provider = context.read<ExchangeProvider>();
    final result = await provider.acceptRequest(request.id ?? '', postId, request.requesterId);

    if (!result.isSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error ?? 'Failed to accept request.')));
    }
  }

  void _onRejectPressed(BuildContext context) async {
    final provider = context.read<ExchangeProvider>();
    final result = await provider.rejectRequest(request.id ?? '', postId);

    if (!result.isSuccess && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.error ?? 'Failed to reject request.')));
    }
  }
}