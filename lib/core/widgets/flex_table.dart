import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// One column definition for [FlexTable]: [flex] controls its share of the
/// table's total width (so the table always fills exactly 100% of whatever
/// width it's given — tablet or phone — with no fixed pixel widths and no
/// horizontal scrolling).
class FlexColumn {
  const FlexColumn({required this.label, this.flex = 1});

  final String label;
  final int flex;
}

/// A table that always fits the width it's laid out in. Each cell is
/// wrapped in [FittedBox] so a value that's still too long for its column
/// on a narrow phone scales down instead of overflowing or forcing a
/// horizontal scrollbar. Used by both Bag Detail's Diamond Details/Bag RM
/// Summary tables and Design Master's Bill Of Material/Lab Details tables,
/// so all four read as one consistent table style across the app.
class FlexTable extends StatelessWidget {
  const FlexTable({
    required this.columns,
    required this.rows,
    required this.isEmpty,
    super.key,
    this.rowTrailing,
  });

  final List<FlexColumn> columns;
  final List<List<String>> rows;
  final bool isEmpty;

  /// Optional trailing widget per data row (e.g. a delete button), appended
  /// after the flex columns in a fixed-width slot; the header row reserves
  /// the same blank width so columns still line up. Left null (no width
  /// reserved at all) by every other [FlexTable] call site, which stays
  /// completely unaffected.
  final Widget Function(int rowIndex)? rowTrailing;

  static const double _trailingWidth = 36;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ColoredBox(
                color: AppColors.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSm,
                    vertical: AppDimensions.spacingSm,
                  ),
                  child: Row(
                    children: [
                      for (int c = 0; c < columns.length; c++) ...[
                        if (c > 0) const SizedBox(width: AppDimensions.spacingSm),
                        Expanded(
                          flex: columns[c].flex,
                          child: FlexCell(
                            text: columns[c].label.toUpperCase(),
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.primaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ],
                      if (rowTrailing != null) const SizedBox(width: _trailingWidth),
                    ],
                  ),
                ),
              ),
              if (isEmpty)
                Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: Text(
                    AppStrings.noDataAvailable,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textHint),
                  ),
                )
              else
                for (int r = 0; r < rows.length; r++)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: r.isEven ? AppColors.surface : AppColors.background,
                      border: const Border(top: BorderSide(color: AppColors.divider)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSm,
                        vertical: AppDimensions.spacingSm,
                      ),
                      child: Row(
                        children: [
                          for (int c = 0; c < columns.length; c++) ...[
                            if (c > 0) const SizedBox(width: AppDimensions.spacingSm),
                            Expanded(
                              flex: columns[c].flex,
                              child: FlexCell(text: rows[r][c]),
                            ),
                          ],
                          if (rowTrailing != null) ...[
                            const SizedBox(width: AppDimensions.spacingSm),
                            SizedBox(width: _trailingWidth, child: Center(child: rowTrailing!(r))),
                          ],
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class FlexCell extends StatelessWidget {
  const FlexCell({required this.text, this.style, super.key});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Text(
          text,
          maxLines: 1,
          textAlign: TextAlign.center,
          style: style ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
