import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/widgets/headers/app_header.dart';
import 'package:project/core/widgets/buttons/primary_button.dart';
import 'package:project/features/feed/widgets/item_header.dart';
import 'package:project/features/feed/widgets/item_image_section.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';

class FeedItemScreen extends StatelessWidget {
  final PostModel post;
  final UserModel? user;
  final String? distance;

  const FeedItemScreen({
    super.key,
    required this.post,
    this.user,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isReserved = post.status == PostStatus.reserved;

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
            ItemHeader(post: post, user: user, distance: distance),
            SizedBox(height: 12),
            ItemImageSection(post: post),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailItem(
                    theme,
                    'Product Description',
                    post.description,
                  ),
                  Divider(color: borderColor, height: 24),
                  _buildDetailItem(
                    theme,
                    'Best Before',
                    DateFormatter.formatDate(post.expirationDate),
                  ),
                  Divider(color: borderColor, height: 24),
                  _buildDetailItem(
                    theme,
                    'Pickup Location',
                    '${post.locationName}\n${distance ?? "0.0 km"} away from you',
                  ),
                  Divider(color: borderColor, height: 24),
                  _buildDetailItem(
                    theme,
                    'Posting date',
                    DateFormatter.formatDateTime(post.createdAt),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: _buildBottomAction(context, isReserved),
        ),
      ),
    );
  }

  Widget _buildDetailItem(ThemeData theme, String label, String value) {
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
            fontWeight: FontWeight.normal,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomAction(BuildContext context, bool isReserved) {
    final exchangeProvider = context.watch<ExchangeProvider>();
    final isAlreadyRequested = exchangeProvider.requests.any(
      (request) =>
          request.postId == post.id &&
          (request.status == RequestStatus.pending ||
              request.status == RequestStatus.accepted),
    );

    if (isReserved) {
      return PrimaryButton(text: 'Item Already Reserved', onPressed: null);
    }

    if (isAlreadyRequested) {
      return PrimaryButton(text: 'Item Already Requested', onPressed: null);
    }

    return PrimaryButton(
      text: 'Request Item',
      onPressed: () => context.push(
        '/request',
        extra: {'post': post, 'user': user, 'distance': distance},
      ),
    );
  }
}
