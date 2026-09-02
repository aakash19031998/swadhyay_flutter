import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../routes/app_routes.dart';
import '../theme/app_colors.dart';

/// Opens [AppRoutes.bagScanner] and drops a scanned value straight into
/// whatever search field this sits beside — same square icon-button shape
/// used by Bag List, QC Pending Dashboard's QC Bag List, and QC Checker.
class ScanButton extends StatelessWidget {
  const ScanButton({required this.onScanned, this.height = AppDimensions.formFieldHeight, super.key});

  final ValueChanged<String> onScanned;

  /// `null` (QC Checker's own usage) lets the button stretch to match a
  /// sibling field's height instead of forcing its own fixed square size —
  /// every other call site keeps the default fixed height.
  final double? height;

  Future<void> _openScanner() async {
    // Deliberately untyped: Get.toNamed<String>(...) throws at runtime
    // ("GetPageRoute<dynamic> is not a subtype of Route<String?>") because
    // app_pages.dart's route table is registered as GetPage<dynamic> — the
    // generic type argument here fights that, not matches it. Casting the
    // dynamic result afterward avoids the mismatch entirely.
    final dynamic result = await Get.toNamed(AppRoutes.bagScanner);
    final String? scanned = result is String ? result : null;
    if (scanned != null && scanned.isNotEmpty) onScanned(scanned);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
        onTap: _openScanner,
        child: SizedBox(
          width: AppDimensions.formFieldHeight,
          height: height,
          child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.onPrimary),
        ),
      ),
    );
  }
}
