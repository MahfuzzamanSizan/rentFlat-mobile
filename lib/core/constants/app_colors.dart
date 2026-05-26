import 'package:flutter/material.dart';

class AppColors {
  // Brand
  static const Color primary = Color(0xFF1A3D6B);
  static const Color primaryLight = Color(0xFF2B5EA7);
  static const Color primaryDark = Color(0xFF0F2547);
  static const Color secondary = Color(0xFF2B87D1);
  static const Color accent = Color(0xFFF0A500);
  static const Color accentLight = Color(0xFFFFC947);

  // Backgrounds
  static const Color background = Color(0xFFF4F6FA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8F9FC);

  // Semantic
  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF57F17);
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color info = Color(0xFF0277BD);
  static const Color infoLight = Color(0xFFE1F5FE);

  // Text
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Colors.white;

  // Borders & Dividers
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);

  // Shadows
  static const Color cardShadow = Color(0x14000000);
  static const Color shadowMedium = Color(0x1E000000);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Status badges
  static const Color pending = Color(0xFFF57F17);
  static const Color approved = Color(0xFF2E7D32);
  static const Color rejected = Color(0xFFE53935);
  static const Color rented = Color(0xFF1565C0);
  static const Color expired = Color(0xFF6B7280);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [primaryDark, primary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
