import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Roboto text styles, aligned to the Material 3 type scale.
///
/// Flutter's Material library bundles Roboto as its built-in fallback font
/// on every platform (Android, iOS, desktop, web), so declaring
/// `fontFamily: 'Roboto'` here renders identically everywhere without
/// shipping extra font assets or a runtime font-fetch dependency.
class AppTypography {
  const AppTypography._();

  static const String fontFamily = 'Roboto';

  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 57,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    displayMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 45,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    displaySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 36,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
    ),
    headlineLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    headlineSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    titleSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    bodyLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      letterSpacing: 0.15,
    ),
    bodyMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.textPrimary,
      letterSpacing: 0.25,
    ),
    bodySmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      letterSpacing: 0.4,
    ),
    labelLarge: TextStyle(
      fontFamily: fontFamily,
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      letterSpacing: 0.1,
    ),
    labelMedium: TextStyle(
      fontFamily: fontFamily,
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
    labelSmall: TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: AppColors.textSecondary,
      letterSpacing: 0.5,
    ),
  );
}
