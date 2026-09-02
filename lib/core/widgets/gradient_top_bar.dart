import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// Gradient app-bar-like header (back button + title) used at the top of
/// several report/detail screens — Artist Production Report, QC Checker
/// Report, Timing Report, Brand Specification, and the Brand PDF viewer.
class GradientTopBar extends StatelessWidget {
  const GradientTopBar({
    required this.title,
    super.key,
    this.onBack,
    this.expandTitle = false,
  });

  final String title;

  /// Defaults to [Get.back] when omitted.
  final VoidCallback? onBack;

  /// `false` (the report/list screens): the title sits directly in the
  /// [Row] at its own intrinsic width, no truncation. `true` (Brand PDF
  /// viewer, whose title is a dynamic filename): the title is wrapped in
  /// [Expanded] with single-line ellipsis, plus a trailing spacer so the
  /// row stays visually balanced against the leading back button.
  final bool expandTitle;

  @override
  Widget build(BuildContext context) {
    final Widget titleText = Text(
      title,
      maxLines: 1,
      overflow: expandTitle ? TextOverflow.ellipsis : null,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
    );

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              onPressed: onBack ?? Get.back,
            ),
            if (expandTitle) ...[
              Expanded(child: titleText),
              const SizedBox(width: AppDimensions.spacingMd),
            ] else
              titleText,
          ],
        ),
      ),
    );
  }
}
