import 'package:flutter/material.dart';

class ToggleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback? onPressed;

  const ToggleButton({
    super.key,
    required this.text,
    this.isSelected = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Shared style for both states to "hug" the text
    final baseStyle = OutlinedButton.styleFrom(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );

    return isSelected
        ? FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: baseStyle.minimumSize?.resolve({}),
              padding: baseStyle.padding?.resolve({}),
              tapTargetSize: baseStyle.tapTargetSize,
            ),
            onPressed: onPressed,
            child: Text(text),
          )
        : OutlinedButton(
            style: baseStyle,
            onPressed: onPressed,
            child: Text(text),
          );
  }
}
