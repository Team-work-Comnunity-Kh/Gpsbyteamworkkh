import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight.withOpacity(0.3),
      onPrimaryContainer: isDark ? Colors.white : AppColors.primaryDark,
      secondary: AppColors.accent,
      onSecondary: Colors.white,
      secondaryContainer: AppColors.accentLight.withOpacity(0.3),
      onSecondaryContainer: AppColors.accentDark,
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
      surfaceContainerHighest: isDark ? AppColors.cardDark : const Color(0xFFF0F4F8),
      error: AppColors.error,
      onError: Colors.white,
      outline: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
    );

    final textTheme = _buildTextTheme(isDark);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),

      // Navigation Bar (Bottom)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        indicatorColor: AppColors.primary.withOpacity(0.2),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.primary);
          }
          return IconThemeData(
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w600
                : FontWeight.normal,
          );
        }),
        elevation: 0,
        shadowColor: Colors.black26,
        surfaceTintColor: Colors.transparent,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isDark
              ? const BorderSide(color: Color(0xFF374151), width: 0.5)
              : BorderSide.none,
        ),
      ),

      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          side: const BorderSide(color: AppColors.primary),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFD1D5DB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
        hintStyle: TextStyle(
          color: isDark ? const Color(0xFF4B5563) : const Color(0xFF9CA3AF),
        ),
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF3F4F6),
        selectedColor: AppColors.primary.withOpacity(0.2),
        labelStyle: textTheme.bodySmall,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // FAB
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: CircleBorder(),
      ),

      // Divider
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF2D3748) : const Color(0xFFE5E7EB),
        thickness: 0.5,
      ),

      // Bottom Sheet
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      // Dialog
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      ),
    );
  }

  static TextTheme _buildTextTheme(bool isDark) {
    final color = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final secColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    // Use Noto Sans Khmer for primary text (supports Khmer Unicode)
    return TextTheme(
      displayLarge: GoogleFonts.notoSansKhmer(fontSize: 57, fontWeight: FontWeight.w400, color: color),
      displayMedium: GoogleFonts.notoSansKhmer(fontSize: 45, fontWeight: FontWeight.w400, color: color),
      displaySmall: GoogleFonts.notoSansKhmer(fontSize: 36, fontWeight: FontWeight.w400, color: color),
      headlineLarge: GoogleFonts.notoSansKhmer(fontSize: 32, fontWeight: FontWeight.w600, color: color),
      headlineMedium: GoogleFonts.notoSansKhmer(fontSize: 28, fontWeight: FontWeight.w600, color: color),
      headlineSmall: GoogleFonts.notoSansKhmer(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      titleLarge: GoogleFonts.notoSansKhmer(fontSize: 22, fontWeight: FontWeight.w600, color: color),
      titleMedium: GoogleFonts.notoSansKhmer(fontSize: 16, fontWeight: FontWeight.w500, color: color),
      titleSmall: GoogleFonts.notoSansKhmer(fontSize: 14, fontWeight: FontWeight.w500, color: color),
      bodyLarge: GoogleFonts.notoSansKhmer(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: GoogleFonts.notoSansKhmer(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      bodySmall: GoogleFonts.notoSansKhmer(fontSize: 12, fontWeight: FontWeight.w400, color: secColor),
      labelLarge: GoogleFonts.notoSansKhmer(fontSize: 14, fontWeight: FontWeight.w600, color: color),
      labelMedium: GoogleFonts.notoSansKhmer(fontSize: 12, fontWeight: FontWeight.w500, color: color),
      labelSmall: GoogleFonts.notoSansKhmer(fontSize: 11, fontWeight: FontWeight.w400, color: secColor),
    );
  }
}
