import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../theme/app_colors.dart';

/// [DropdownMenu]-based dropdown — unlike the plain [AppDropdown]
/// ([DropdownButtonFormField]), its popup list always opens anchored
/// directly below the field (Material's stock dropdown instead aligns the
/// menu around whichever item is currently selected, which reads as
/// "ugly"/misplaced), with tight per-item padding and no leading
/// selection-indicator icon. The field itself still picks up the app's
/// shared form-field border/padding via the global `dropdownMenuTheme`, so
/// it reads as the same field style as every other input — only the list
/// is different. First used for the Bag Completion screen's Work
/// Type/Work fields; reused wherever else a dropdown needs this look (e.g.
/// Timing Report's month picker).
class AppModernDropdown<T> extends StatelessWidget {
  const AppModernDropdown({
    required this.label,
    required this.icon,
    required this.items,
    required this.itemLabel,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final IconData icon;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T>(
      // Rebuilds fresh whenever `value` changes so `initialSelection` (only
      // ever applied on first build, otherwise) always reflects it.
      key: ValueKey(value),
      initialSelection: value,
      enabled: onChanged != null,
      expandedInsets: EdgeInsets.zero,
      requestFocusOnTap: false,
      label: Text(label),
      leadingIcon: Icon(icon),
      onSelected: onChanged,
      menuStyle: MenuStyle(
        backgroundColor: const WidgetStatePropertyAll(AppColors.surface),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(6),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            side: const BorderSide(color: AppColors.border),
          ),
        ),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(vertical: AppDimensions.spacingXxs)),
      ),
      dropdownMenuEntries: [
        for (final item in items)
          DropdownMenuEntry<T>(
            value: item,
            label: itemLabel(item),
            style: MenuItemButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingXs,
              ),
            ),
          ),
      ],
    );
  }
}
