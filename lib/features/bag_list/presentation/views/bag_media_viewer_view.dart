import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../controllers/bag_media_viewer_controller.dart';

/// Full-screen image/video gallery — shared by the Bag List screen's
/// thumbnail and the Design Master screen's image card, so both open the
/// exact same viewer instead of two near-identical ones.
class BagMediaViewerView extends GetView<BagMediaViewerController> {
  const BagMediaViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // Full-screen Scaffold; SafeArea (not a full-bleed Stack) just keeps
      // the media itself from sitting behind the status bar or this
      // screen's own top bar — it's laid out in the space between them.
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(controller: controller),
            Expanded(
              // [imageSize] is capped off the smaller of the two available
              // dimensions (not just width, like a plain AspectRatio would)
              // so it plus the thumbnail strip below always fits the actual
              // remaining space — never taller than the screen. The frame
              // itself is wider than that — extra white space around the
              // image, not a bigger image — while video is free to use the
              // full frame width.
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const double reservedHeight = AppDimensions.bagThumbnailSize + AppDimensions.spacingMd;
                  final double maxImageWidth = constraints.maxWidth - AppDimensions.spacingXl * 2;
                  final double maxImageHeight = constraints.maxHeight - reservedHeight;
                  final double imageSize = (maxImageWidth < maxImageHeight ? maxImageWidth : maxImageHeight)
                      .clamp(0, double.infinity);
                  final double frameWidth = constraints.maxWidth - AppDimensions.spacingSm * 2;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: frameWidth,
                        height: imageSize,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                            ),
                            // Swipe-to-change-page is disabled while zoomed
                            // in (see BagMediaViewerController.isZoomed) —
                            // panning a zoomed-in image with one finger
                            // would otherwise fight the PageView's own
                            // horizontal drag for the same gesture, which
                            // is what made pinch/pan feel unreliable.
                            child: Obx(
                              () => PageView.builder(
                                controller: controller.pageController,
                                physics: controller.isZoomed.value
                                    ? const NeverScrollableScrollPhysics()
                                    : const PageScrollPhysics(),
                                itemCount: controller.media.length,
                                onPageChanged: controller.onPageChanged,
                                itemBuilder: (context, index) => _MediaPage(
                                  item: controller.media[index],
                                  controller: controller,
                                  imageSize: imageSize,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppDimensions.spacingMd),
                      _ThumbnailStrip(controller: controller),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.controller});

  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMd,
        vertical: AppDimensions.spacingSm,
      ),
      child: Row(
        children: [
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingSm,
                vertical: AppDimensions.spacingXxs,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              ),
              child: Text(
                '${controller.currentIndex.value + 1} / ${controller.media.length}',
                style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.surface),
              onPressed: Get.back,
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaPage extends StatelessWidget {
  const _MediaPage({required this.item, required this.controller, required this.imageSize});

  final BagMediaEntity item;
  final BagMediaViewerController controller;

  /// Fixed display size for images — kept the same regardless of how wide
  /// the surrounding frame is, so widening the frame only adds white space
  /// around the image, never enlarges the image itself. Video pages ignore
  /// this and use the full frame width instead.
  final double imageSize;

  @override
  Widget build(BuildContext context) {
    if (item.type == BagMediaType.image) {
      return _ZoomableImage(url: item.url, imageSize: imageSize, controller: controller);
    }

    return _VideoPage(controller: controller);
  }
}

/// Pinch-to-zoom (via [InteractiveViewer]) plus a smooth, animated
/// double-tap zoom centered on the tapped point — toggling between 1x and
/// [_zoomScale] — instead of [InteractiveViewer]'s pinch gesture alone.
/// Reports its zoom state up to [controller] so the enclosing `PageView`
/// can stop competing with panning for the same one-finger drag gesture.
class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.url, required this.imageSize, required this.controller});

  final String url;
  final double imageSize;
  final BagMediaViewerController controller;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage> with SingleTickerProviderStateMixin {
  static const double _zoomScale = 2.5;

  final TransformationController _transformationController = TransformationController();
  late final AnimationController _animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  Animation<Matrix4>? _zoomAnimation;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _animationController.addListener(() {
      final Animation<Matrix4>? animation = _zoomAnimation;
      if (animation != null) _transformationController.value = animation.value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(begin: _transformationController.value, end: target).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward(from: 0);
  }

  void _onDoubleTapDown(TapDownDetails details) => _doubleTapDetails = details;

  void _onDoubleTap() {
    final bool isZoomedIn = _transformationController.value.getMaxScaleOnAxis() > 1.01;
    if (isZoomedIn) {
      _animateTo(Matrix4.identity());
      widget.controller.setZoomed(false);
      return;
    }

    final Offset position = _doubleTapDetails?.localPosition ?? Offset.zero;
    final Matrix4 target = Matrix4.identity()
      ..translateByDouble(-position.dx * (_zoomScale - 1), -position.dy * (_zoomScale - 1), 0, 1)
      ..scaleByDouble(_zoomScale, _zoomScale, _zoomScale, 1);
    _animateTo(target);
    widget.controller.setZoomed(true);
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    widget.controller.setZoomed(_transformationController.value.getMaxScaleOnAxis() > 1.01);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _onDoubleTapDown,
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1,
        maxScale: 4,
        onInteractionEnd: _onInteractionEnd,
        child: Center(
          child: SizedBox(
            width: widget.imageSize,
            height: widget.imageSize,
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.contain,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
              errorWidget: (context, url, error) => const Icon(
                Icons.image_not_supported_outlined,
                color: AppColors.textHint,
                size: AppDimensions.iconXl,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoPage extends StatelessWidget {
  const _VideoPage({required this.controller});

  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.hasVideoError.value) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline_rounded, color: AppColors.textHint, size: AppDimensions.iconXl),
              const SizedBox(height: AppDimensions.spacingSm),
              Text(
                AppStrings.videoUnavailable,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppDimensions.spacingMd),
              TextButton.icon(
                onPressed: controller.retryVideo,
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                label: Text(AppStrings.retry, style: const TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        );
      }

      final VideoPlayerController? player = controller.videoController.value;
      if (!controller.isVideoReady.value || player == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.primary));
      }

      return Center(
        child: GestureDetector(
          onTap: controller.toggleVideoPlayback,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: player.value.aspectRatio,
                child: VideoPlayer(player),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: controller.isVideoPlaying.value ? 0 : 1,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingMd),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primaryDark, AppColors.primary, AppColors.primaryLight],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.5),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.onPrimary,
                    size: AppDimensions.iconXl,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

/// Centered under the media, not a left-anchored full-width list — a
/// `ListView` always stretches to fill its available width even with only
/// a couple of items, so this uses a scrollable `Row` inside [Center]
/// instead: it sits centered when it fits, and still scrolls normally once
/// there are enough thumbnails to overflow.
class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({required this.controller});

  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.bagThumbnailSize,
      child: Center(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int index = 0; index < controller.media.length; index++) ...[
                if (index > 0) const SizedBox(width: AppDimensions.spacingSm),
                _ThumbnailTile(controller: controller, index: index),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ThumbnailTile extends StatelessWidget {
  const _ThumbnailTile({required this.controller, required this.index});

  final BagMediaViewerController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    final BagMediaEntity item = controller.media[index];

    return Obx(() {
      final bool selected = controller.currentIndex.value == index;

      return GestureDetector(
        onTap: () => controller.selectThumbnail(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          width: AppDimensions.bagThumbnailSize,
          height: AppDimensions.bagThumbnailSize,
          transform: selected ? (Matrix4.identity()..scaleByDouble(1.08, 1.08, 1.08, 1)) : Matrix4.identity(),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primaryLight : Colors.white.withValues(alpha: 0.24),
              width: selected ? 2.5 : 1,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryLight.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd - 2),
            child: item.type == BagMediaType.image
                ? CachedNetworkImage(imageUrl: item.url, fit: BoxFit.cover)
                : ColoredBox(
                    color: AppColors.textPrimary,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppDimensions.spacingXxs),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: AppColors.surface, size: AppDimensions.iconSm),
                      ),
                    ),
                  ),
          ),
        ),
      );
    });
  }
}
