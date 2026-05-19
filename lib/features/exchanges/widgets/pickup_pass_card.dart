import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';
import 'package:project/core/models/request_model.dart';
import 'package:project/core/models/user_model.dart';
import 'package:project/features/exchanges/providers/exchange_provider.dart';
import 'package:project/core/utils/date_formatter.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:project/core/widgets/common/loading_screen.dart';
import 'package:project/core/widgets/buttons/secondary_button.dart';

class PickupPassCard extends StatefulWidget {
  final PostModel post;
  final UserModel receiver;
  final RequestModel request;

  const PickupPassCard({
    super.key,
    required this.post,
    required this.receiver,
    required this.request,
  });

  @override
  State<PickupPassCard> createState() => _PickupPassCardState();
}

class _PickupPassCardState extends State<PickupPassCard> {
  bool _isCancelling = false;

  @override
  Widget build(BuildContext context) {
    if (_isCancelling) {
      return const LoadingScreen(
        title: 'Cancelling pickup',
        subtitle: 'Updating request status. Please wait...',
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final now = DateTime.now();
    final oneHourBeforePickup = widget.request.pickupDatetime.subtract(
      const Duration(hours: 1),
    );
    final canCancel = now.isBefore(oneHourBeforePickup);

    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.neutral900 : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppColors.neutral800 : AppColors.neutral200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.primary500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  "Pickup Pass",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.neutral800
                          : Colors.grey.withOpacity(0.2),
                      width: 1.5,
                    ),
                  ),
                  child: QrImageView(
                    data: 'shareup:${widget.post.id}',
                    version: QrVersions.auto,
                    size: 220.0,
                    gapless: false,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Colors.black,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Scan to verify transaction",
                  style: TextStyle(
                    color: isDark ? AppColors.neutral400 : AppColors.neutral500,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: List.generate(
                    32,
                    (index) => Expanded(
                      child: Container(
                        color: index % 2 == 0
                            ? Colors.transparent
                            : (isDark
                                  ? AppColors.neutral700
                                  : Colors.grey[300]),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildPassRow(
                  context,
                  label: "Reserved for",
                  value: widget.receiver.username,
                  avatarUrl: widget.receiver.profileImage,
                ),
                const SizedBox(height: 16),
                _buildPassRow(
                  context,
                  icon: Icons.calendar_month_outlined,
                  label: "Pickup Schedule",
                  value: DateFormatter.formatDateTime(
                    widget.request.pickupDatetime,
                  ),
                  iconColor: const Color(0xFFFBC02D),
                  iconBgColor: const Color(0xFFFFF9C4),
                ),
                const SizedBox(height: 16),
                _buildPassRow(
                  context,
                  icon: Icons.location_on_outlined,
                  label: "Pickup Location",
                  value: widget.post.locationName,
                  iconColor: const Color(0xFF42A5F5),
                  iconBgColor: const Color(0xFFE3F2FD),
                ),
                const SizedBox(height: 24),
                if (!canCancel) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.warning500.withValues(alpha: 0.15)
                          : AppColors.warning50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? AppColors.warning500.withValues(alpha: 0.3)
                            : AppColors.warning500.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: isDark
                              ? AppColors.warning500
                              : AppColors.warning900,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Pickup can't be cancelled within 1 hour.",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.warning
                                  : AppColors.warning900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (widget.post.status != PostStatus.completed)
                  SecondaryButton(
                    text: "Cancel Pickup",
                    onPressed: canCancel ? () => _handleCancel(context) : null,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context) async {
    setState(() => _isCancelling = true);
    final exchangeProvider = context.read<ExchangeProvider>();
    final result = await exchangeProvider.cancelRequest(
      widget.request.id!,
      widget.post.id!,
    );

    if (mounted) {
      setState(() => _isCancelling = false);
      if (result.isSuccess) {
        Navigator.of(context).pop();
      }
    }
  }

  Widget _buildPassRow(
    BuildContext context, {
    required String label,
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
        child: avatarUrl.isEmpty
            ? const Icon(Icons.person, size: 18, color: Colors.white)
            : null,
      );
    } else {
      leadingWidget = Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDark
              ? (iconColor?.withOpacity(0.15) ?? Colors.transparent)
              : (iconBgColor ?? Colors.transparent),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isDark
              ? (iconColor ?? Colors.grey[400])
              : (iconColor ?? Colors.grey[500]),
        ),
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
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
        ),
      ],
    );
  }
}
