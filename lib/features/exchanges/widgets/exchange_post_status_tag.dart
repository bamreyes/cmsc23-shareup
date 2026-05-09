import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/post_model.dart';

class ExchangePostStatusTag extends StatelessWidget {
  final PostStatus status;

  const ExchangePostStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color accentColor;
    String label;

    switch (status) {
      case PostStatus.reserved:
        backgroundColor = AppColors.warning50;
        accentColor = AppColors.statusReserved;
        label = 'Reserved';
        break;
      case PostStatus.available:
        backgroundColor = AppColors.success50;
        accentColor = AppColors.statusActive;
        label = 'Available';
        break;
      case PostStatus.completed:
        backgroundColor = const Color(0xFFEFF6FF);
        accentColor = AppColors.statusDone;
        label = 'Completed';
        break;
      case PostStatus.deleted:
        backgroundColor = AppColors.error50;
        accentColor = AppColors.statusExpired;
        label = 'Expired';
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
