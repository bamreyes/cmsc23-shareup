import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';

class ExpirationTag extends StatelessWidget {
  final DateTime expirationDate;

  const ExpirationTag({super.key, required this.expirationDate});

  static const _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  @override
  Widget build(BuildContext context) {
    final color = AppColors.expiryColor(expirationDate);
    final label =
        '${_monthNames[expirationDate.month - 1]} ${expirationDate.day}';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_today, size: 12, color: Colors.white),
          SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
