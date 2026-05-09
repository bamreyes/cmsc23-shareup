import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';

class ExchangeDetailRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const ExchangeDetailRow({
    super.key,
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.neutral100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.neutral500, size: 16),
        ),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: AppColors.neutral400,
            fontWeight: FontWeight.w600,
          ),
        ),
        Spacer(),
        Text(
          detail,
          style: TextStyle(fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
