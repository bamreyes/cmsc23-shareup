import 'package:flutter/material.dart';

class DietaryTagColors {
  DietaryTagColors._();

  static const Map<String, Color> _tagColors = {
    'Vegan': Color(0xFF22C55E),
    'Vegetarian': Color(0xFF84CC16),
    'Halal': Color(0xFF06B6D4),
    'Pescatarian': Color(0xFF3B82F6),
    'Gluten-Free': Color(0xFFF59E0B),
    'Dairy-Free': Color(0xFF8B5CF6),
    'Keto-Friendly': Color(0xFFEC4899),
    'Raw Ingredients': Color(0xFFF97316),
    'Home-Cooked': Color(0xFFEAB308),
    'Baked Goods': Color(0xFFD97706),
    'Packaged': Color(0xFF64748B),
    'Fresh Produced': Color(0xFF10B981),
    'Nut-Free': Color(0xFFEF4444),
    'Egg-Free': Color(0xFFA855F7),
    'Shellfish-Free': Color(0xFFF43F5E),
  };

  static Color colorFor(String tag) {
    return _tagColors[tag] ?? const Color(0xFF64748B);
  }

  static Color backgroundFor(String tag) {
    return colorFor(tag).withValues(alpha: 0.08);
  }
}
