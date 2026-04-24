import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import 'extensions/smooth_page_indicator_theme.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary500,
        primary: AppColors.primary500,
        onPrimary: AppColors.neutral0,
        primaryContainer: AppColors.primary100,
        onPrimaryContainer: AppColors.primary900,
        secondary: AppColors.statusDone, // Info blue
        error: AppColors.error500,
        onSurface: AppColors.neutral900,
        surface: AppColors.neutral0,
        surfaceContainerLowest: AppColors.neutral0,
        surfaceContainerLow: AppColors.neutral50,
      ),
      textTheme: GoogleFonts.interTextTheme(),
      scaffoldBackgroundColor: AppColors.neutral100,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral50,
        foregroundColor: AppColors.neutral950,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral0,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neutral200, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.primary50,
          elevation: 8,
          shadowColor: const Color(0xFF1BDC2E).withValues(alpha: 0.2),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.neutral0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary600, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral0,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.neutral200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary500, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.error500),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.neutral50,
        indicatorColor: AppColors.primary600,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary600,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.primary950,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.neutral50, size: 20);
          }
          return const IconThemeData(color: AppColors.primary950, size: 20);
        }),
      ),
      extensions: [
        SmoothPageIndicatorThemeExtension(
          activeDotColor: AppColors.primary600,
          dotColor: AppColors.neutral300,
          dotWidth: 8.0,
          dotHeight: 8.0,
        ),
      ],
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary500,
        brightness: Brightness.dark,
        primary: AppColors.primary500,
        onPrimary: AppColors.neutral0,
        primaryContainer: AppColors.primary900,
        onPrimaryContainer: AppColors.primary100,
        surface: AppColors.neutral950,
        onSurface: AppColors.neutral100,
        surfaceContainerLow: AppColors.neutral900,
      ),
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      scaffoldBackgroundColor: AppColors.neutral950,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.neutral950,
        foregroundColor: AppColors.neutral100,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.neutral900,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.neutral800, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.primary50,
          elevation: 0,
          shadowColor: AppColors.primary500.withValues(alpha: 0.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary600,
          foregroundColor: AppColors.neutral0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.primary600, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          minimumSize: const Size.fromHeight(40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.neutral900,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.neutral800),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.neutral800),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AppColors.primary500, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.neutral950,
        indicatorColor: AppColors.primary600,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary400,
            );
          }
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.neutral400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.neutral0, size: 18);
          }
          return const IconThemeData(color: AppColors.neutral100, size: 20);
        }),
      ),
      extensions: [
        SmoothPageIndicatorThemeExtension(
          activeDotColor: AppColors.primary500,
          dotColor: AppColors.neutral700,
          dotWidth: 8.0,
          dotHeight: 8.0,
        ),
      ],
    );
  }
}
