import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../features/qc_pending_dashboard/domain/entities/dia_qc_checker_entity.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// "Diamond QC Checker" dropdown — used by both the QC Pending Dashboard
/// and QC Checker screens.
class DiamondQcCheckerField extends StatelessWidget {
  const DiamondQcCheckerField({
    required this.options,
    required this.selected,
    required this.onSelect,
    super.key,
    this.rebuildKey,
  });

  final RxList<DiaQcCheckerEntity> options;
  final Rxn<DiaQcCheckerEntity> selected;
  final ValueChanged<DiaQcCheckerEntity> onSelect;

  /// QC Pending Dashboard forces the dropdown to rebuild fresh whenever the
  /// selected department changes (its own choice narrows the option list);
  /// QC Checker doesn't need this, so it's left null there.
  final Object? rebuildKey;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<DiaQcCheckerEntity> items = options;
      final DiaQcCheckerEntity? value = selected.value;

      return DropdownButtonFormField<DiaQcCheckerEntity>(
        key: rebuildKey == null ? null : ValueKey(rebuildKey),
        initialValue: value,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
        hint: Text(
          AppStrings.selectDiamondQcChecker,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.diamond_outlined, color: AppColors.primary),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(AppDimensions.radiusMd))),
          contentPadding:
              EdgeInsets.symmetric(horizontal: AppDimensions.spacingXs, vertical: AppDimensions.spacingSm),
          filled: true,
          fillColor: AppColors.surface,
        ),
        selectedItemBuilder: (context) => [
          for (final option in items)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.qcName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
        items: [
          for (final option in items)
            DropdownMenuItem(
              value: option,
              child: Text('${option.qcName} (${option.qcCode})', overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: items.isEmpty ? null : (value) => onSelect(value!),
      );
    });
  }
}
