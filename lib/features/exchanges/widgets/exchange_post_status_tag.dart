import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';

class ExchangePostStatusTag extends StatelessWidget {
  final PostStatus status;

  const ExchangePostStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color backgroundColor;
    Color accentColor;
    String label;

    switch (status) {
      case PostStatus.reserved:
        accentColor = AppColors.statusReserved;
        backgroundColor = isDark
            ? accentColor.withValues(alpha: 0.15)
            : AppColors.warning50;
        label = 'Reserved';
        break;
      case PostStatus.available:
        accentColor = AppColors.statusActive;
        backgroundColor = isDark
            ? accentColor.withValues(alpha: 0.15)
            : AppColors.success50;
        label = 'Available';
        break;
      case PostStatus.completed:
        accentColor = AppColors.statusDone;
        backgroundColor = isDark
            ? accentColor.withValues(alpha: 0.15)
            : const Color(0xFFEFF6FF);
        label = 'Completed';
        break;
      case PostStatus.deleted:
        accentColor = AppColors.statusExpired;
        backgroundColor = isDark
            ? accentColor.withValues(alpha: 0.15)
            : AppColors.error50;
        label = 'Deleted';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
