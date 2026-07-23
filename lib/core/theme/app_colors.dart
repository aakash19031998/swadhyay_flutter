import 'package:flutter/material.dart';

/// Brand and semantic color tokens. Widgets must reference these constants
/// (or the derived [ColorScheme] via `Theme.of(context).colorScheme`) —
/// never an inline `Color(0x...)`.
class AppColors {
  const AppColors._();

  // Brand.
  static const Color primary = Color(0xFF323C84);
  static const Color primaryDark = Color(0xFF232A5E);
  static const Color primaryLight = Color(0xFF5C66AD);
  static const Color primaryContainer = Color(0xFFE4E6F5);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Neutrals / surfaces.
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F5F9);
  static const Color surfaceVariant = Color(0xFFEEF0F8);
  static const Color border = Color(0xFFE1E3ED);
  static const Color divider = Color(0xFFE6E8F0);

  // Text.
  static const Color textPrimary = Color(0xFF1B1D2A);
  static const Color textSecondary = Color(0xFF6B7080);
  static const Color textHint = Color(0xFFA0A4B8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic.
  static const Color success = Color(0xFF1E8E5A);
  static const Color successDark = Color(0xFF146B45);
  static const Color successContainer = Color(0xFFE1F5EA);
  static const Color warning = Color(0xFFB77E12);
  static const Color warningContainer = Color(0xFFFBF0DD);
  static const Color error = Color(0xFFC62828);
  static const Color errorContainer = Color(0xFFFBE9E9);
  static const Color info = Color(0xFF1565C0);
  static const Color infoContainer = Color(0xFFE3EDFB);

  // Utility.
  static const Color disabled = Color(0xFFC7CADA);
  static const Color shimmerBase = Color(0xFFE8E9F0);
  static const Color shimmerHighlight = Color(0xFFF6F7FB);
  static const Color overlayScrim = Color(0x99000000);

  // Chart. `success` doubles as the "used" series; this is the dedicated
  // "unused" series color — distinct hue from every other token above so
  // the two bars never get confused with status/semantic colors elsewhere.
  static const Color chartAmber = Color(0xFFF5B400);
}
