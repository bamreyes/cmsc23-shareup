import 'package:flutter/material.dart';
import '../../constants/dietary_tag_colors.dart';
import '../../constants/colors.dart';

class Tag extends StatelessWidget {
  final String label;
  final Color? color;
  final Color? textColor;
  final bool isFilled;

  const Tag({
    super.key,
    required this.label,
    this.color,
    this.textColor,
    this.isFilled = false,
  });

  @override
  Widget build(BuildContext context) {
    final tagColor = color ?? DietaryTagColors.colorFor(label);
    final bgColor = DietaryTagColors.backgroundFor(label);
    final effectiveTextColor = textColor ?? tagColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? tagColor : bgColor,
        border: Border.all(color: tagColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: isFilled ? AppColors.neutral100 : effectiveTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
