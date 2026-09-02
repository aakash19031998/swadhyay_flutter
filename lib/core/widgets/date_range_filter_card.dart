import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../helpers/date_time_helper.dart';
import 'app_button.dart';
import 'bordered_surface_card.dart';

/// Date-range filter as its own floating card (rounded, bordered, shadowed)
/// — used by both the Artist Production Report and QC Checker Report
/// screens. Reactive params (rather than already-resolved plain values) so
/// each field keeps its own independent `Obx`, same as before.
class DateRangeFilterCard extends StatelessWidget {
  const DateRangeFilterCard({
    required this.fromDate,
    required this.toDate,
    required this.isLoading,
    required this.onPickFromDate,
    required this.onPickToDate,
    required this.onShow,
    super.key,
  });

  final Rx<DateTime> fromDate;
  final Rx<DateTime?> toDate;
  final RxBool isLoading;
  final Future<void> Function(BuildContext context) onPickFromDate;
  final Future<void> Function(BuildContext context) onPickToDate;
  final VoidCallback onShow;

  @override
  Widget build(BuildContext context) {
    return BorderedSurfaceCard(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isTablet = constraints.maxWidth >= AppDimensions.breakpointPhone;

          final Widget fromField = Obx(
            () => _DateField(
              label: AppStrings.fromDate,
              date: fromDate.value,
              onTap: () => onPickFromDate(context),
            ),
          );
          final Widget toField = Obx(
            () => _DateField(
              label: AppStrings.toDate,
              date: toDate.value,
              onTap: () => onPickToDate(context),
            ),
          );
          final Widget showButton = Obx(
            () => AppButton(
              label: AppStrings.show,
              icon: Icons.search,
              fullWidth: false,
              isLoading: isLoading.value,
              onPressed: onShow,
            ),
          );

          if (isTablet) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: fromField),
                const SizedBox(width: AppDimensions.spacingMd),
                Expanded(child: toField),
                const SizedBox(width: AppDimensions.spacingMd),
                showButton,
              ],
            );
          }

          return Column(
            children: [
              fromField,
              const SizedBox(height: AppDimensions.spacingSm),
              toField,
              const SizedBox(height: AppDimensions.spacingSm),
              Align(alignment: Alignment.centerRight, child: showButton),
            ],
          );
        },
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.date, required this.onTap});

  final String label;

  /// Null when To date has been cleared after a From date change — the
  /// user must tap through and pick a new one before Show will run.
  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.formFieldRadius),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: AppDimensions.iconSm),
        ),
        child: Text(
          date != null ? DateTimeHelper.formatDate(date!) : AppStrings.selectDate,
          style: date == null ? TextStyle(color: Theme.of(context).hintColor) : null,
        ),
      ),
    );
  }
}
