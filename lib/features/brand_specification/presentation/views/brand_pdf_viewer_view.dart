import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/hk_loader_card.dart';
import '../controllers/brand_pdf_viewer_controller.dart';

/// Renders a specification PDF entirely in-app via [PdfViewPinch] — no
/// download, no "open with"/share handoff to another app, and no save
/// affordance anywhere in this screen's own chrome.
class BrandPdfViewerView extends GetView<BrandPdfViewerController> {
  const BrandPdfViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(title: controller.title),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const HkLoaderCard();
                if (controller.errorMessage.value != null) {
                  return AppErrorWidget(message: controller.errorMessage.value!, onRetry: controller.load);
                }
                final PdfControllerPinch pdfController = controller.pdfController!;
                return Stack(
                  children: [
                    Positioned.fill(child: PdfViewPinch(controller: pdfController)),
                    Positioned(
                      top: 0,
                      right: 0,
                      bottom: 0,
                      child: _PageScrollbar(controller: pdfController),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

/// Vertical scrollbar hugging the right edge — a track + a draggable thumb
/// sized/positioned by the current page, reactive to
/// [PdfControllerPinch.pageListenable]. Built by hand (not Flutter's
/// [Scrollbar] widget) because [PdfViewPinch] is backed by
/// [PdfControllerPinch] (a [TransformationController]/[InteractiveViewer]),
/// not a [Scrollable] with a [ScrollPosition] a [Scrollbar] could attach to.
/// The thumb itself is the drag surface — dragging it with a finger jumps
/// straight to that page, the same way a native fast-scroll thumb works.
class _PageScrollbar extends StatefulWidget {
  const _PageScrollbar({required this.controller});

  final PdfControllerPinch controller;

  @override
  State<_PageScrollbar> createState() => _PageScrollbarState();
}

class _PageScrollbarState extends State<_PageScrollbar> {
  static const double _trackMargin = AppDimensions.spacingMd;
  static const double _hitAreaWidth = 44;
  static const double _thumbWidth = 8;
  static const double _thumbWidthActive = 14;
  static const double _minThumbHeight = 56;

  /// `pdfx`'s `animateToPage` always drives a real `AnimationController`
  /// tick *and* a page re-render, even with `Duration.zero` — calling it on
  /// every raw `onVerticalDragUpdate` (dozens of events/second) is what
  /// made dragging feel laggy. The thumb's on-screen position now updates
  /// instantly via plain [setState] (cheap, no PDF work); the actual page
  /// navigation is debounced to this interval instead.
  static const Duration _navigateDebounce = Duration(milliseconds: 80);

  bool _dragging = false;

  /// Page implied by the thumb's current position while dragging — null
  /// when not dragging, in which case the thumb just reflects the
  /// controller's real current page.
  int? _dragPage;

  int _lastNavigatedPage = 1;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  int _pageForOffset(double localDy, double trackHeight, double thumbHeight, int total) {
    final double usableRange = trackHeight - thumbHeight;
    final double desiredTop = (localDy - _trackMargin - thumbHeight / 2).clamp(0.0, usableRange);
    final double fraction = usableRange <= 0 ? 0 : desiredTop / usableRange;
    return ((fraction * (total - 1)).round() + 1).clamp(1, total);
  }

  void _onTouch(int page) {
    if (_dragPage != page) setState(() => _dragPage = page);
    _debounce?.cancel();
    _debounce = Timer(_navigateDebounce, () => _navigate(page));
  }

  void _navigate(int page) {
    if (page == _lastNavigatedPage) return;
    _lastNavigatedPage = page;
    widget.controller.animateToPage(pageNumber: page, duration: Duration.zero, curve: Curves.linear);
  }

  void _endDrag() {
    _debounce?.cancel();
    final int? finalPage = _dragPage;
    if (finalPage != null) _navigate(finalPage);
    setState(() {
      _dragging = false;
      _dragPage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PdfPageNumber(
      controller: widget.controller,
      builder: (context, loadingState, page, pagesCount) {
        final int total = pagesCount ?? 1;
        if (total <= 1) return const SizedBox.shrink();

        final int displayPage = _dragPage ?? page;

        return LayoutBuilder(
          builder: (context, constraints) {
            final double trackHeight = constraints.maxHeight - _trackMargin * 2;
            final double thumbHeight = (trackHeight / total).clamp(_minThumbHeight, trackHeight);
            final double usableRange = trackHeight - thumbHeight;
            final double thumbTop =
                _trackMargin + (usableRange <= 0 ? 0 : (displayPage - 1) / (total - 1) * usableRange);
            final double thumbWidth = _dragging ? _thumbWidthActive : _thumbWidth;

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragStart: (details) {
                setState(() => _dragging = true);
                _onTouch(_pageForOffset(details.localPosition.dy, trackHeight, thumbHeight, total));
              },
              onVerticalDragUpdate: (details) =>
                  _onTouch(_pageForOffset(details.localPosition.dy, trackHeight, thumbHeight, total)),
              onVerticalDragEnd: (_) => _endDrag(),
              onVerticalDragCancel: _endDrag,
              child: SizedBox(
                width: _hitAreaWidth,
                height: constraints.maxHeight,
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Positioned(
                      right: _hitAreaWidth / 2 - 1.5,
                      top: _trackMargin,
                      bottom: _trackMargin,
                      width: 3,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.textPrimary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.spacingXxs),
                        ),
                      ),
                    ),
                    if (_dragging)
                      Positioned(
                        right: _hitAreaWidth + AppDimensions.spacingSm,
                        top: (thumbTop + thumbHeight / 2 - 14).clamp(0.0, constraints.maxHeight - 28),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.spacingSm,
                            vertical: AppDimensions.spacingXxs,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.textPrimary.withValues(alpha: 0.85),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                          ),
                          child: Text(
                            '$displayPage / $total',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.onPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                      ),
                    AnimatedPositioned(
                      duration: _dragging ? Duration.zero : const Duration(milliseconds: 150),
                      curve: Curves.easeOut,
                      right: _hitAreaWidth / 2 - thumbWidth / 2,
                      top: thumbTop,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: thumbWidth,
                        height: thumbHeight,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: _dragging ? 1 : 0.55),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXs),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.onPrimary),
              onPressed: Get.back,
            ),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingMd),
          ],
        ),
      ),
    );
  }
}
