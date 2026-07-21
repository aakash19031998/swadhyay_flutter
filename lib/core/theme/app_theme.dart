import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the Material 3 [ThemeData] for the app.
///
/// Only [light] is wired into `GetMaterialApp` today (product requirement:
/// "Support Light Theme"), but [dark] is fully built out — following the
/// same seed and component overrides — so enabling dark mode later is a
/// `themeMode` flip, not a redesign.
class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(brightness: Brightness.light);

  static ThemeData get dark => _build(brightness: Brightness.dark);

  static ThemeData _build({required Brightness brightness}) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: brightness,
    ).copyWith(
      primary: isDark ? AppColors.primaryLight : AppColors.primary,
      onPrimary: AppColors.onPrimary,
      primaryContainer: AppColors.primaryContainer,
      error: AppColors.error,
      errorContainer: AppColors.errorContainer,
      surface: isDark ? AppColors.textPrimary : AppColors.surface,
      onSurface: isDark ? AppColors.surface : AppColors.textPrimary,
    );

    final TextTheme textTheme = isDark
        ? AppTypography.textTheme.apply(
            bodyColor: AppColors.surface,
            displayColor: AppColors.surface,
          )
        : AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      scaffoldBackgroundColor: isDark ? AppColors.primaryDark : AppColors.background,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: AppDimensions.elevationNone,
        centerTitle: false,
        titleTextStyle: AppTypography.textTheme.titleLarge?.copyWith(
          color: AppColors.onPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.onPrimary),
      ),
      cardTheme: CardThemeData(
        color: isDark ? AppColors.primaryDark : AppColors.surface,
        elevation: AppDimensions.elevationLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          side: BorderSide(color: AppColors.border.withValues(alpha: isDark ? 0.2 : 1)),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingMd,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        hintStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        labelStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.disabled,
          minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          textStyle: AppTypography.textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(AppDimensions.buttonMinWidth, AppDimensions.buttonHeight),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.primary,
        textColor: AppColors.textPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTypography.textTheme.bodyMedium?.copyWith(color: AppColors.surface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: isDark ? AppColors.primaryDark : AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        ),
      ),
      progressIndicatorTheme: ThemeData().progressIndicatorTheme.copyWith(
            color: colorScheme.primary,
          ),
      dropdownMenuTheme: DropdownMenuThemeData(
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
