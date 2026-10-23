import 'package:flutter/material.dart';

/// SmartGPS Color Palette
/// Primary: Teal #0FA3A3, Accent: Orange #FF6B35
abstract class AppColors {
  // ─── Primary (Teal) ────────────────────────────────────────────────
  static const Color primary = Color(0xFF0FA3A3);
  static const Color primaryLight = Color(0xFF4DB6AC);
  static const Color primaryDark = Color(0xFF007979);

  // ─── Accent (Orange) ───────────────────────────────────────────────
  static const Color accent = Color(0xFFFF6B35);
  static const Color accentLight = Color(0xFFFF8A65);
  static const Color accentDark = Color(0xFFE64A19);

  // ─── Backgrounds ──────────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);
  static const Color cardDark = Color(0xFF2A2A2A);

  // ─── Text ─────────────────────────────────────────────────────────
  static const Color textPrimaryLight = Color(0xFF1A1A2E);
  static const Color textPrimaryDark = Color(0xFFF0F0F0);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);

  // ─── GPS Signal Levels ─────────────────────────────────────────────
  static const Color signalStrong = Color(0xFF22C55E);   // Green — ខ្លាំង
  static const Color signalMedium = Color(0xFFF59E0B);  // Amber — មធ្យម
  static const Color signalWeak = Color(0xFFEF4444);     // Red — ខ្សោយ
  static const Color signalNone = Color(0xFF9CA3AF);     // Gray — គ្មាន

  // ─── Map Overlays ──────────────────────────────────────────────────
  static const Color parcelFill = Color(0x330FA3A3);
  static const Color parcelStroke = Color(0xFF0FA3A3);
  static const Color trackLine = Color(0xFFFF6B35);
  static const Color geofenceFill = Color(0x22FF6B35);
  static const Color geofenceStroke = Color(0xFFFF6B35);
  static const Color waypointPin = Color(0xFF0FA3A3);

  // ─── Status ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── SOS ─────────────────────────────────────────────────────────
  static const Color sos = Color(0xFFDC2626);
  static const Color sosLight = Color(0xFFFEE2E2);

  // ─── Gradients ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0FA3A3), Color(0xFF007979)],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0FA3A3), Color(0xFF004D4D)],
  );
}
