import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';

class ExpirationTag extends StatelessWidget {
  final DateTime expirationDate;

  const ExpirationTag({super.key, required this.expirationDate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = expirationDate.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours;

    String label;
    Color color;

    if (difference.isNegative) {
      label = "Expired";
      color = AppColors.error500;
    } else if (hours < 1) {
      final mins = difference.inMinutes;
      label = "Expires in ${mins}m";
      color = AppColors.error500;
    } else if (hours < 24) {
      label = "Expires in ${hours}h";
      color = AppColors.error500;
    } else if (days == 1) {
      label = "Expires tomorrow";
      color = AppColors.warning500;
    } else {
      label = "Expires in $days days";
      color = AppColors.primary500;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
