import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/network/connectivity_checker.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_widget.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/common_app_bar.dart';
import '../../../../core/widgets/flex_table.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../bag_list/presentation/controllers/bag_media_viewer_args.dart';
import '../../domain/entities/design_bom_item_entity.dart';
import '../../domain/entities/design_lab_detail_entity.dart';
import '../../domain/entities/design_master_entity.dart';
import '../controllers/design_image_controller.dart';

/// Search-first, single-record lookup screen: only the search bar shows
/// until a style number is searched, then the full record — image, General
/// specs, Bill Of Material, Lab Details and History — is revealed below it.
class DesignImageView extends GetView<DesignImageController> {
  const DesignImageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: AppStrings.designImage, showNotification: false),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppDimensions.spacingMd),
              child: _DesignImageSearchBar(onSearch: controller.search, onClear: controller.reset),
            ),
            Expanded(child: Obx(() => _buildBody(context))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (!controller.hasSearched.value) {
      return const AppEmptyWidget(message: AppStrings.designMasterSearchPrompt, icon: Icons.search_rounded);
    }
    if (controller.isLoading.value) return const AppLoader();

    final DesignMasterEntity? design = controller.result.value;
    if (design == null) {
      return const AppEmptyWidget(message: AppStrings.designMasterNotFound, icon: Icons.search_off_rounded);
    }

    return _DesignMasterDetail(design: design, tabController: controller.tabController);
  }
}

/// Search field + dedicated Search button, side by side. Unlike the shared
/// `AppSearchField` (debounced, fires on every keystroke), typing here does
/// nothing on its own — [onSearch] only fires when the button is tapped or
/// the keyboard's search action is used, so results never jump around
/// mid-type.
class _DesignImageSearchBar extends StatefulWidget {
  const _DesignImageSearchBar({required this.onSearch, required this.onClear});

  final ValueChanged<String> onSearch;
  final VoidCallback onClear;

  @override
  State<_DesignImageSearchBar> createState() => _DesignImageSearchBarState();
}

class _DesignImageSearchBarState extends State<_DesignImageSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _triggerSearch() async {
    FocusScope.of(context).unfocus();
    if (!await Get.find<ConnectivityChecker>().ensureConnected()) return;
    widget.onSearch(_controller.text);
  }

  void _clear() {
    _controller.clear();
    setState(() {});
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SizedBox(
            height: AppDimensions.formFieldHeight,
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _triggerSearch(),
              textInputAction: TextInputAction.search,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                isDense: true,
                hintText: AppStrings.designImageSearchHint,
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(icon: const Icon(Icons.close_rounded), onPressed: _clear),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingMd,
                ),
                filled: true,
                fillColor: AppColors.surface,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        _SearchButton(onTap: _triggerSearch),
      ],
    );
  }
}

/// Gradient, elevated icon+label button — the only thing that actually
/// triggers a search, matching [_DesignImageSearchBarState]'s tap-to-search
/// functionality. Same [AppDimensions.formFieldHeight] as the search field
/// beside it, so the two line up exactly.
class _SearchButton extends StatelessWidget {
  const _SearchButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.formFieldHeight,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.search_rounded, color: AppColors.onPrimary, size: AppDimensions.iconSm),
                  const SizedBox(width: AppDimensions.spacingXs),
                  Text(
                    AppStrings.search,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The single design record: title/"Active Record" header, the image
/// (tap opens the full image/video gallery — same `BagMediaViewerView` the
/// Bag List screen uses) with its preview chip, then the General/Bill Of
/// Material/Lab Details/History tabs.
class _DesignMasterDetail extends StatelessWidget {
  const _DesignMasterDetail({required this.design, required this.tabController});

  final DesignMasterEntity design;
  final TabController tabController;

  void _openMediaGallery() {
    if (design.media.isEmpty) return;
    Get.toNamed(AppRoutes.bagMediaViewer, arguments: BagMediaViewerArgs(media: design.media));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppDimensions.spacingMd,
        0,
        AppDimensions.spacingMd,
        AppDimensions.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DesignHeader(design: design),
          const SizedBox(height: AppDimensions.spacingMd),
          _DesignImageCard(design: design, onTap: _openMediaGallery),
          const SizedBox(height: AppDimensions.spacingMd),
          SectionCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Column(
                children: [
                  _SegmentedTabBar(tabController: tabController),
                  // Swaps the visible tab content directly off the tab
                  // index — same as Bag Detail's Diamond Details/Bag RM
                  // Summary tabs — so the section's height always matches
                  // exactly whichever tab is currently selected, instead of
                  // a fixed height shared by all four.
                  AnimatedBuilder(
                    animation: tabController,
                    builder: (context, _) {
                      switch (tabController.index) {
                        case 0:
                          return _GeneralTab(design: design);
                        case 1:
                          return _BomTab(items: design.bomItems);
                        case 2:
                          return _LabTab(items: design.labDetails);
                        default:
                          return _HistoryTab(history: design.history);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Same pill-segmented look and height as Bag Detail's Diamond Details/Bag
/// RM Summary tab bar — a filled pill indicator sliding between equal-width
/// segments — except each segment shows its icon to the left of its label
/// (Bag Detail's two tabs are text-only) instead of stacked above it.
class _SegmentedTabBar extends StatelessWidget {
  const _SegmentedTabBar({required this.tabController});

  final TabController tabController;

  static const List<_TabData> _tabs = [
    _TabData(Icons.description_outlined, AppStrings.generalTab),
    _TabData(Icons.grid_view_rounded, AppStrings.billOfMaterialTab),
    _TabData(Icons.science_outlined, AppStrings.labDetailsTab),
    _TabData(Icons.history_rounded, AppStrings.historyTab),
  ];

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.surfaceVariant,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.spacingXs),
        child: SizedBox(
          height: AppDimensions.bagDetailSegmentedTabBarHeight,
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: AppColors.onPrimary,
            unselectedLabelColor: AppColors.textSecondary,
            labelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
            tabs: [
              for (final tab in _tabs)
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(tab.icon, size: AppDimensions.iconSm),
                      const SizedBox(width: AppDimensions.spacingXxs),
                      Flexible(child: Text(tab.label, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData(this.icon, this.label);

  final IconData icon;
  final String label;
}

class _DesignHeader extends StatelessWidget {
  const _DesignHeader({required this.design});

  final DesignMasterEntity design;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                design.designCode.toUpperCase(),
                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: AppDimensions.spacingXxs),
              Text(AppStrings.designMasterSubtitle, style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: AppDimensions.spacingSm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingSm, vertical: AppDimensions.spacingXxs),
          decoration: BoxDecoration(
            color: AppColors.successContainer,
            border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.circle, color: AppColors.success, size: 8),
              const SizedBox(width: AppDimensions.spacingXxs),
              Text(
                AppStrings.activeRecord,
                style: textTheme.labelMedium?.copyWith(color: AppColors.success, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Just the image, in a plain white card — nothing overlaid on top of it.
/// The "tap to view" hint sits below the card instead.
class _DesignImageCard extends StatelessWidget {
  const _DesignImageCard({required this.design, required this.onTap});

  final DesignMasterEntity design;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: AppDimensions.designMasterImageSize,
              height: AppDimensions.designMasterImageSize,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
                child: CachedNetworkImage(
                  imageUrl: design.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  errorWidget: (context, url, error) => const ColoredBox(
                    color: AppColors.surfaceVariant,
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.textHint,
                      size: AppDimensions.iconXl,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (design.media.isNotEmpty) ...[
            const SizedBox(height: AppDimensions.spacingSm),
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.photo_library_outlined, size: AppDimensions.iconSm, color: AppColors.onPrimary),
                    const SizedBox(width: AppDimensions.spacingXs),
                    Text(
                      '${AppStrings.viewGallery} · ${design.media.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Manually built row-by-row (not `GridView`, which needs a bounded
/// height) so this tab's height stays intrinsic/content-driven — same
/// reasoning as Bag Detail's `_BagSummaryCard` grid.
class _GeneralTab extends StatelessWidget {
  const _GeneralTab({required this.design});

  final DesignMasterEntity design;

  @override
  Widget build(BuildContext context) {
    final List<_FieldData> fields = [
      _FieldData(Icons.qr_code_2_outlined, AppStrings.designCode, design.designCode),
      _FieldData(Icons.category_outlined, AppStrings.designCtg, design.designCtg),
      _FieldData(Icons.bookmark_outline, AppStrings.designSctg, design.designSctg),
      _FieldData(Icons.extension_outlined, AppStrings.parts, design.parts),
      _FieldData(Icons.style_outlined, AppStrings.emrStyle, design.emrStyle),
      _FieldData(Icons.event_outlined, AppStrings.designDate, design.designDate),
      _FieldData(Icons.diamond_outlined, AppStrings.totalDiaWt, design.totalDiaWt),
      _FieldData(Icons.straighten_outlined, AppStrings.defRingSize, design.defRingSize),
      _FieldData(Icons.view_in_ar_outlined, AppStrings.cadWt, design.cadWt),
      _FieldData(Icons.scale_outlined, AppStrings.modelWt, design.modelWt),
      _FieldData(Icons.aspect_ratio_outlined, AppStrings.cadVol, design.cadVol),
      _FieldData(Icons.monitor_weight_outlined, AppStrings.metalWt, design.metalWt),
    ];

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int columns = constraints.maxWidth > AppDimensions.breakpointPhone
              ? 4
              : (constraints.maxWidth > 380 ? 2 : 1);

          final List<Widget> tiles = [
            for (int i = 0; i < fields.length; i++) _GeneralFieldTile(data: fields[i], index: i),
          ];

          final List<Widget> rows = [
            for (int i = 0; i < tiles.length; i += columns)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (int c = 0; c < columns; c++) ...[
                    if (c > 0) const SizedBox(width: AppDimensions.spacingXs),
                    Expanded(child: i + c < tiles.length ? tiles[i + c] : const SizedBox()),
                  ],
                ],
              ),
          ];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: AppDimensions.spacingXs),
                rows[i],
              ],
            ],
          );
        },
      ),
    );
  }
}

class _FieldData {
  const _FieldData(this.icon, this.label, this.value);

  final IconData icon;
  final String label;
  final String value;
}

/// Same icon-badge chip recipe and accent color cycle as Bag Detail's Bag
/// Summary tiles — just smaller (tighter padding, smaller badge) to suit
/// this screen's denser 12-field grid.
class _GeneralFieldTile extends StatelessWidget {
  const _GeneralFieldTile({required this.data, required this.index});

  final _FieldData data;
  final int index;

  static const List<Color> _accents = [
    AppColors.info,
    AppColors.warning,
    AppColors.success,
    AppColors.primary,
  ];
  static const List<Color> _accentContainers = [
    AppColors.infoContainer,
    AppColors.warningContainer,
    AppColors.successContainer,
    AppColors.primaryContainer,
  ];

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final Color accent = _accents[index % _accents.length];
    final Color accentContainer = _accentContainers[index % _accentContainers.length];

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingXs),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: AppDimensions.designMasterChipBadgeSize,
            height: AppDimensions.designMasterChipBadgeSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accentContainer,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(data.icon, size: AppDimensions.iconSm, color: accent),
          ),
          const SizedBox(width: AppDimensions.spacingXs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.label.toUpperCase(),
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  data.value.isEmpty ? '—' : data.value,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Same [FlexTable] shell as Bag Detail's Diamond Details table — no
/// horizontal scrolling, cells scale down to fit instead of overflowing.
class _BomTab extends StatelessWidget {
  const _BomTab({required this.items});

  final List<DesignBomItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return FlexTable(
      isEmpty: items.isEmpty,
      columns: const [
        FlexColumn(label: AppStrings.srNo, flex: 1),
        FlexColumn(label: AppStrings.rmType, flex: 1),
        FlexColumn(label: AppStrings.rmCode, flex: 2),
        FlexColumn(label: AppStrings.sizeName, flex: 2),
        FlexColumn(label: AppStrings.pcs, flex: 1),
        FlexColumn(label: AppStrings.rmWeight, flex: 1),
        FlexColumn(label: AppStrings.setCode, flex: 1),
        FlexColumn(label: AppStrings.stonePosition, flex: 2),
      ],
      rows: [
        for (final item in items)
          [
            '${item.srNo}',
            item.rmType,
            item.rmCode,
            item.sizeName,
            item.pcs,
            item.rmWeight,
            item.setCode,
            item.stonePosition,
          ],
      ],
    );
  }
}

/// Same [FlexTable] shell as Bag Detail's Bag RM Summary table.
class _LabTab extends StatelessWidget {
  const _LabTab({required this.items});

  final List<DesignLabDetailEntity> items;

  @override
  Widget build(BuildContext context) {
    return FlexTable(
      isEmpty: items.isEmpty,
      columns: const [
        FlexColumn(label: AppStrings.labourCd, flex: 1),
        FlexColumn(label: AppStrings.labourNm, flex: 2),
        FlexColumn(label: AppStrings.pcs, flex: 1),
      ],
      rows: [
        for (final item in items) [item.labourCd, item.labourNm, item.pcs],
      ],
    );
  }
}

/// A colored, gradient-tinted activity card instead of a flat gray box —
/// [AppColors.info] is used here specifically (rather than the primary
/// color used everywhere else on this screen) so History reads as its own
/// distinct, "log entry" accent among the four tabs.
class _HistoryTab extends StatelessWidget {
  const _HistoryTab({required this.history});

  final String history;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(AppDimensions.spacingLg),
        child: AppEmptyWidget(message: AppStrings.noDataAvailable, icon: Icons.history_rounded),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.spacingMd),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.infoContainer, AppColors.infoContainer.withValues(alpha: 0.3)],
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          border: Border.all(color: AppColors.info.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppDimensions.designMasterChipBadgeSize,
                  height: AppDimensions.designMasterChipBadgeSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.info,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.info.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.history_rounded, color: AppColors.onPrimary, size: AppDimensions.iconSm),
                ),
                const SizedBox(width: AppDimensions.spacingSm),
                Text(
                  AppStrings.historyTab,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.info, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.spacingSm),
            Container(height: 1, color: AppColors.info.withValues(alpha: 0.15)),
            const SizedBox(height: AppDimensions.spacingSm),
            Text(
              history,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6, color: AppColors.textPrimary),
            ),
          ],
        ),
      ),
    );
  }
}
