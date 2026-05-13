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
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    if (isSelected) {
      final color = activeColor ?? Theme.of(context).primaryColor;
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
      style: baseStyle,
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
