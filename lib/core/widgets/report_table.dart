import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// Generic gradient-header/zebra-row table — used by the Artist Production
/// Report and QC Checker Report screens. Cells are full [Widget]s (not just
/// strings) so a column can hold a badge/icon instead of plain text, and an
/// optional [footer] renders as the table's last row (e.g. a total-points
/// bar) inside the same rounded/clipped block.
class ReportTable extends StatefulWidget {
  const ReportTable({
    required this.columns,
    required this.rows,
    super.key,
    this.footer,
    this.fillHeight = true,
  });

  final List<Widget> columns;
  final List<List<Widget>> rows;
  final Widget? footer;

  /// `true`: rows fill whatever height the card is given and scroll
  /// internally, so a long list never pushes [footer] off-screen — for a
  /// table that sits inside a fixed-height layout of its own (QC Checker
  /// Report's Prediction Score Matrix). `false`: the table wraps its own
  /// content height instead, so a card doesn't get stretched to match a
  /// sibling and leave dead space below its rows — for a table whose
  /// surrounding screen already scrolls as a whole (Artist Production
  /// Report; QC Checker Report's Shift & Process Distribution, typically
  /// only a handful of rows).
  final bool fillHeight;

  @override
  State<ReportTable> createState() => _ReportTableState();
}

class _ReportTableState extends State<ReportTable> {
  // Explicit controller (rather than letting `Scrollbar` auto-detect the
  // nearest `Scrollable`) so the thumb reliably attaches to *this* table's
  // own row list — auto-detection is fragile once a table like this sits
  // inside other scrollables/rebuilding ancestors.
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> columns = widget.columns;
    final List<List<Widget>> rows = widget.rows;
    final Widget? footer = widget.footer;
    final bool fillHeight = widget.fillHeight;
    final TextTheme textTheme = Theme.of(context).textTheme;

    final List<Widget> rowWidgets = [
      for (int i = 0; i < rows.length; i++)
        DecoratedBox(
          decoration: BoxDecoration(
            color: i.isEven ? AppColors.surface : AppColors.surfaceVariant,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMd,
              vertical: AppDimensions.spacingSm,
            ),
            child: Row(
              children: [for (final cell in rows[i]) Expanded(child: Center(child: cell))],
            ),
          ),
        ),
    ];

    return Column(
      mainAxisSize: fillHeight ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingMd,
            vertical: AppDimensions.spacingSm,
          ),
          child: Row(
            children: [for (final column in columns) Expanded(child: column)],
          ),
        ),
        if (rows.isEmpty)
          fillHeight
              ? Expanded(
                  child: Center(
                    child: Text(
                      AppStrings.noDataFound,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(AppDimensions.spacingLg),
                  child: Text(
                    AppStrings.noDataFound,
                    style: textTheme.bodyMedium?.copyWith(color: AppColors.textHint),
                  ),
                )
        else if (!fillHeight)
          // Wraps its own content height — no forced fill, no internal
          // scroll.
          Column(children: rowWidgets)
        else
          // `Expanded` + internal scroll (rather than a fixed height cap)
          // so the rows fill whatever space the card is actually given —
          // [footer] (e.g. the "Total Points" bar) stays pinned right
          // below them instead of needing a further page-scroll to reach.
          Expanded(
            // `thumbVisibility: true` keeps the thumb drawn (not just a
            // transient fade-in on drag) — but only when the rows
            // actually overflow the available height; a short list that
            // fits with no scrolling paints no thumb at all regardless.
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(children: rowWidgets),
              ),
            ),
          ),
        ?footer,
      ],
    );
  }
}

/// A plain header-row label — centered, single line, ellipsized — used as a
/// [ReportTable] column header.
class ReportHeaderLabel extends StatelessWidget {
  const ReportHeaderLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
    );
  }
}

/// A plain text value cell — centered, single line, ellipsized — used as a
/// [ReportTable] row cell for columns that only ever hold text (no
/// badge/icon).
class ReportValueCell extends StatelessWidget {
  const ReportValueCell({required this.text, super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Text(text, maxLines: 1, textAlign: TextAlign.center, overflow: TextOverflow.ellipsis, style: style),
    );
  }
}
