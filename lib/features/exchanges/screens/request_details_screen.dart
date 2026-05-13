import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/widgets/buttons/secondary_button.dart';
import 'package:project/features/feed/widgets/item_header.dart';
import 'package:project/features/feed/widgets/item_image_section.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';

class RequestDetailsScreen extends StatelessWidget {
  final RequestModel request;
  final PostModel post;
  final UserModel postOwner;

  const RequestDetailsScreen({
    super.key,
    required this.request,
    required this.post,
    required this.postOwner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderColor = theme.brightness == Brightness.light
        ? AppColors.grey200
        : AppColors.neutral800;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppHeader.close(
        title: 'Item Details',
        onClose: () => context.pop(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ItemHeader(post: post, user: postOwner),
            SizedBox(height: 12),
            ItemImageSection(post: post),
            SizedBox(height: 24),

            _buildSectionContainer(theme, borderColor, [
              _buildDetailItem(theme, 'Product Description', post.description),
              Divider(color: borderColor, height: 24),
              _buildDetailItem(
                theme,
                'Best Before',
                DateFormatter.formatDate(post.expirationDate),
              ),
              Divider(color: borderColor, height: 24),
              _buildDetailItem(theme, 'Pickup Location', post.locationName),
              Divider(color: borderColor, height: 24),
              _buildDetailItem(
                theme,
                'Posting date',
                DateFormatter.formatDateTime(post.createdAt),
              ),
            ]),

            SizedBox(height: 16),

            // Additional Request Information Section
            _buildSectionContainer(theme, borderColor, [
              _buildDetailItem(
                theme,
                'Request Status',
                _getStatusText(),
                valueColor: _getStatusColor(),
              ),
              Divider(color: borderColor, height: 24),
              _buildDetailItem(
                theme,
                'Pickup Schedule',
                DateFormatter.formatDateTime(request.pickupDatetime),
              ),
              Divider(color: borderColor, height: 24),
              _buildDetailItem(theme, 'Pickup Location', post.locationName),
            ]),

            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildBottomAction(context),
        ),
      ),
    );
  }

  Widget _buildSectionContainer(
    ThemeData theme,
    Color borderColor,
    List<Widget> children,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailItem(
    ThemeData theme,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final colorScheme = theme.colorScheme;
    final greyColor = theme.brightness == Brightness.light
        ? AppColors.neutral400
        : AppColors.neutral300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: valueColor != null
                ? FontWeight.bold
                : FontWeight.normal,
            color: valueColor ?? colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (request.status) {
      case RequestStatus.pending:
        return 'Pending';
      case RequestStatus.accepted:
        return 'Accepted';
      case RequestStatus.rejected:
        return 'Rejected';
      case RequestStatus.cancelled:
        return 'Cancelled';
      case RequestStatus.completed:
        return 'Completed';
    }
  }

  Color _getStatusColor() {
    switch (request.status) {
      case RequestStatus.pending:
        return AppColors.statusReserved;
      case RequestStatus.accepted:
        return AppColors.statusActive;
      case RequestStatus.rejected:
      case RequestStatus.cancelled:
        return AppColors.statusExpired;
      case RequestStatus.completed:
        return AppColors.statusDone;
    }
  }

  Widget _buildBottomAction(BuildContext context) {
    // Only show cancel button if request is active (pending or accepted)
    if (request.status != RequestStatus.pending &&
        request.status != RequestStatus.accepted) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final oneHourBeforePickup = request.pickupDatetime.subtract(
      const Duration(hours: 1),
    );
    final canCancel = now.isBefore(oneHourBeforePickup);

    return SecondaryButton(
      text: request.status == RequestStatus.accepted
          ? 'Cancel Pickup'
          : 'Cancel Request',
      onPressed: canCancel
          ? () => _handleCancel(context)
          : null, // Disabled if within 1 hour
    );
  }

  void _handleCancel(BuildContext context) async {
    final exchangeProvider = context.read<ExchangeProvider>();
    final result = await exchangeProvider.cancelRequest(request.id!, post.id!);

    if (result.isSuccess && context.mounted) {
      context.pop();
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result.error ?? 'Failed to cancel request')),
      );
    }
  }
}
