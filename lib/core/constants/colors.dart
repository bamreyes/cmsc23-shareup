import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary (Living Green) ─────────────────────────────
  static const Color primary50 = Color(0xFFF1FDE8);
  static const Color primary100 = Color(0xFFDDFAC2);
  static const Color primary200 = Color(0xFFBFF199);
  static const Color primary300 = Color(0xFF89E219);
  static const Color primary400 = Color(0xFF6ED401);
  static const Color primary500 = Color(0xFF58CC02);
  static const Color primary600 = Color(0xFF43C000);
  static const Color primary700 = Color(0xFF379E00);
  static const Color primary800 = Color(0xFF2C7E00);
  static const Color primary900 = Color(0xFF215F00);
  static const Color primary950 = Color(0xFF143A00);

  static const Color primary = primary500;

  // ── Neutral (Grey) ─────────────────────────────
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral50 = Color(0xFFFAFAFA);
  static const Color neutral100 = Color(0xFFF5F5F5);
  static const Color neutral200 = Color(0xFFE5E5E5);
  static const Color neutral300 = Color(0xFFD4D4D4);
  static const Color neutral400 = Color(0xFFA3A3A3);
  static const Color neutral500 = Color(0xFF737373);
  static const Color neutral600 = Color(0xFF525252);
  static const Color neutral700 = Color(0xFF404040);
  static const Color neutral800 = Color(0xFF262626);
  static const Color neutral900 = Color(0xFF171717);
  static const Color neutral950 = Color(0xFF0A0A0A);

  // ── Error (Destructive) ────────────────────────────────
  static const Color error50 = Color(0xFFFDECEC);
  static const Color error500 = Color(0xFFF43F5E);
  static const Color error900 = Color(0xFFC33939);
  static const Color danger = error500;

  // ── Warning (Amber) ────────────────────────────────────
  static const Color warning50 = Color(0xFFFEF3C7);
  static const Color warning500 = Color(0xFFF59E0B);
  static const Color warning900 = Color(0xFFB45309);
  static const Color warning = warning500;

  // ── Success (Emerald) ──────────────────────────────────
  static const Color success50 = Color(0xFFEBFFF1);
  static const Color success500 = Color(0xFF43C000);
  static const Color success900 = Color(0xFF047857);

  // ── Semantic Aliases ───────────────────────────────────
  static const Color white = neutral0;
  static const Color black = neutral950;
  static const Color grey50 = neutral50;
  static const Color grey100 = neutral100;
  static const Color grey200 = neutral200;
  static const Color grey400 = neutral400;
  static const Color grey600 = neutral600;
  static const Color grey800 = neutral800;

  // ── Backgrounds ────────────────────────────────────────
  static const Color scaffoldLight = neutral100;
  static const Color scaffoldDark = neutral950;
  static const Color cardLight = neutral50;
  static const Color cardDark = neutral900;

  // ── Borders ────────────────────────────────────────────
  static const Color borderLight = neutral200;
  static const Color borderDark = neutral800;

  // ── Status badge colors ────────────────────────────────
  static const Color statusActive = success500;
  static const Color statusReserved = warning500;
  static const Color statusExpired = error500;
  static const Color statusDone = Color(0xFF3B82F6); // Info blue

  // ── Helpers ───────────────────────────────────────────
  static Color expiryColor(DateTime expiryDate) {
    final days = expiryDate.difference(DateTime.now()).inDays;
    if (days <= 3) return error500;
    if (days <= 7) return warning500;
    return success500;
  }

  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'reserved':
        return statusReserved;
      case 'expired':
        return statusExpired;
      case 'completed':
        return statusDone;
      default:
        return statusActive;
    }
  }
}
