import 'package:flutter/material.dart';

class AppColors {
  // Brand core
  static const Color primary      = Color(0xFF1A3D6B);
  static const Color primaryLight = Color(0xFF2563EB);
  static const Color primaryDark  = Color(0xFF0A1628);

  // Vibrant accents
  static const Color secondary   = Color(0xFF06B6D4);
  static const Color accent      = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFCD34D);
  static const Color rose        = Color(0xFFF43F5E);
  static const Color violet      = Color(0xFF8B5CF6);
  static const Color emerald     = Color(0xFF10B981);
  static const Color indigo      = Color(0xFF6366F1);

  // Backgrounds
  static const Color background     = Color(0xFFF0F4FF);
  static const Color surface        = Colors.white;
  static const Color surfaceVariant = Color(0xFFF8FAFF);

  // Semantic
  static const Color error        = Color(0xFFEF4444);
  static const Color success      = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning      = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color info         = Color(0xFF06B6D4);
  static const Color infoLight    = Color(0xFFCFFAFE);

  // Text
  static const Color textPrimary   = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textHint      = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // Borders
  static const Color divider = Color(0xFFE2E8F0);
  static const Color border  = Color(0xFFCBD5E1);

  // Shadows
  static const Color cardShadow   = Color(0x0F000000);
  static const Color shadowMedium = Color(0x1A000000);

  // Shimmer
  static const Color shimmerBase      = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Status
  static const Color pending  = Color(0xFFF59E0B);
  static const Color approved = Color(0xFF10B981);
  static const Color rejected = Color(0xFFEF4444);
  static const Color rented   = Color(0xFF6366F1);
  static const Color expired  = Color(0xFF64748B);

  // ── Gradients ─────────────────────────────────────────────────────────────

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A3D6B), Color(0xFF2563EB), Color(0xFF06B6D4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A3D6B), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF060B18),
      Color(0xFF0F172A),
      Color(0xFF1E1B4B),
      Color(0xFF1A3D6B),
    ],
    stops: [0.0, 0.3, 0.65, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFCD34D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient roseGradient = LinearGradient(
    colors: [Color(0xFFBE123C), Color(0xFFF43F5E), Color(0xFFFB7185)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF5B21B6), Color(0xFF8B5CF6), Color(0xFFA78BFA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient tealGradient = LinearGradient(
    colors: [Color(0xFF0E7490), Color(0xFF06B6D4), Color(0xFF22D3EE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    colors: [Color(0xFF065F46), Color(0xFF10B981), Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient indigoGradient = LinearGradient(
    colors: [Color(0xFF3730A3), Color(0xFF6366F1), Color(0xFF818CF8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
