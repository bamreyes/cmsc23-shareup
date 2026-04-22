import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class SmoothPageIndicatorThemeExtension
    extends ThemeExtension<SmoothPageIndicatorThemeExtension> {
  final Color activeDotColor;
  final Color dotColor;
  final double dotWidth;
  final double dotHeight;
  final double spacing;

  const SmoothPageIndicatorThemeExtension({
    required this.activeDotColor,
    required this.dotColor,
    this.dotWidth = 8.0,
    this.dotHeight = 8.0,
    this.spacing = 8.0,
  });

  @override
  SmoothPageIndicatorThemeExtension copyWith({
    Color? activeDotColor,
    Color? dotColor,
    double? dotWidth,
    double? dotHeight,
    double? spacing,
  }) {
    return SmoothPageIndicatorThemeExtension(
      activeDotColor: activeDotColor ?? this.activeDotColor,
      dotColor: dotColor ?? this.dotColor,
      dotWidth: dotWidth ?? this.dotWidth,
      dotHeight: dotHeight ?? this.dotHeight,
      spacing: spacing ?? this.spacing,
    );
  }

  @override
  SmoothPageIndicatorThemeExtension lerp(
    ThemeExtension<SmoothPageIndicatorThemeExtension>? other,
    double t,
  ) {
    if (other is! SmoothPageIndicatorThemeExtension) {
      return this;
    }
    return SmoothPageIndicatorThemeExtension(
      activeDotColor: Color.lerp(activeDotColor, other.activeDotColor, t)!,
      dotColor: Color.lerp(dotColor, other.dotColor, t)!,
      dotWidth: lerpDouble(dotWidth, other.dotWidth, t)!,
      dotHeight: lerpDouble(dotHeight, other.dotHeight, t)!,
      spacing: lerpDouble(spacing, other.spacing, t)!,
    );
  }

  ExpandingDotsEffect get expandingDotsEffect => ExpandingDotsEffect(
    activeDotColor: activeDotColor,
    dotColor: dotColor,
    dotWidth: dotWidth,
    dotHeight: dotHeight,
    spacing: spacing,
    expansionFactor: 4,
  );

  WormEffect get wormEffect => WormEffect(
    activeDotColor: activeDotColor,
    dotColor: dotColor,
    dotWidth: dotWidth,
    dotHeight: dotHeight,
    spacing: spacing,
  );
}
