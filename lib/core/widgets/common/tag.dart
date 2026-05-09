import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = color ?? colorScheme.outline;
    final effectiveTextColor = textColor ?? colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isFilled ? effectiveColor : Colors.transparent,
        border: isFilled ? null : Border.all(color: effectiveColor),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: effectiveTextColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
