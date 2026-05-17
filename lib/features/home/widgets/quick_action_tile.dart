import 'package:flutter/material.dart';
import 'package:project/core/constants/colors.dart';

class QuickActionTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final tileBgColor = isDarkMode ? AppColors.neutral900 : AppColors.neutral50;
    final tileBorderColor = isDarkMode
        ? AppColors.neutral800
        : AppColors.neutral200;
    final textColor = isDarkMode ? AppColors.white : AppColors.neutral800;
    final iconColor = isDarkMode ? AppColors.primary400 : AppColors.primary500;
    final chevronColor = isDarkMode
        ? AppColors.neutral500
        : AppColors.neutral400;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: tileBgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tileBorderColor),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: chevronColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
