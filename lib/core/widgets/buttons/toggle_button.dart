import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;
  final Color? activeColor;

  const ToggleButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = activeColor ?? theme.primaryColor;

    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (isSelected) {
      return FilledButton(
        style: FilledButton.styleFrom(
          minimumSize: baseStyle.minimumSize?.resolve({}),
          padding: baseStyle.padding?.resolve({}),
          tapTargetSize: baseStyle.tapTargetSize,
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
    }

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        minimumSize: baseStyle.minimumSize?.resolve({}),
        padding: baseStyle.padding?.resolve({}),
        tapTargetSize: baseStyle.tapTargetSize,
        foregroundColor: color,
        side: BorderSide(color: color),
        backgroundColor: isDark ? color.withOpacity(0.08) : null,
      ),
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
