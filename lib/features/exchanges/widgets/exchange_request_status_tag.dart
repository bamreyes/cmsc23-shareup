import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';
import 'package:project/core/models/request_model.dart';

class ExchangeRequestStatusTag extends StatelessWidget {
  final RequestStatus status;

  const ExchangeRequestStatusTag({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color accentColor;
    String label;

    switch (status) {
      case RequestStatus.pending:
        backgroundColor = AppColors.warning50;
        accentColor = AppColors.statusReserved;
        label = 'Pending';
        break;
      case RequestStatus.accepted:
        backgroundColor = AppColors.success50;
        accentColor = AppColors.statusActive;
        label = 'Accepted';
        break;
      case RequestStatus.rejected:
        backgroundColor = AppColors.error50;
        accentColor = AppColors.statusExpired;
        label = 'Rejected';
        break;
      case RequestStatus.cancelled:
        backgroundColor = AppColors.error50;
        accentColor = AppColors.statusExpired;
        label = 'Cancelled';
        break;
      case RequestStatus.completed:
        backgroundColor = const Color(0xFFEFF6FF);
        accentColor = AppColors.statusDone;
        label = 'Completed';
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
