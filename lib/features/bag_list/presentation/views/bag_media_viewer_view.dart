import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../controllers/bag_media_viewer_controller.dart';

class BagMediaViewerView extends GetView<BagMediaViewerController> {
  const BagMediaViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(controller: controller),
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.media.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) => _MediaPage(item: controller.media[index], controller: controller),
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _ThumbnailStrip(controller: controller),
            const SizedBox(height: AppDimensions.spacingMd),
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
            () => Text(
              '${controller.currentIndex.value + 1} / ${controller.media.length}',
              style: const TextStyle(color: AppColors.surface, fontWeight: FontWeight.w600),
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: AppColors.surface),
            onPressed: Get.back,
          ),
        ],
      ),
    );
  }
}

class _MediaPage extends StatelessWidget {
  const _MediaPage({required this.item, required this.controller});

  final BagMediaEntity item;
  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    if (item.type == BagMediaType.image) {
      return InteractiveViewer(
        minScale: 1,
        maxScale: 4,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: item.url,
            fit: BoxFit.contain,
            placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.surface),
            errorWidget: (context, url, error) => const Icon(
              Icons.image_not_supported_outlined,
              color: AppColors.textHint,
              size: AppDimensions.iconXl,
            ),
          ),
        ),
      );
    }

    return _VideoPage(controller: controller);
  }
}

class _VideoPage extends StatelessWidget {
  const _VideoPage({required this.controller});

  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final VideoPlayerController? player = controller.videoController.value;
      if (!controller.isVideoReady.value || player == null) {
        return const Center(child: CircularProgressIndicator(color: AppColors.surface));
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
              if (!controller.isVideoPlaying.value)
                Container(
                  padding: const EdgeInsets.all(AppDimensions.spacingSm),
                  decoration: BoxDecoration(
                    color: AppColors.overlayScrim,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.surface,
                    size: AppDimensions.iconXl,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _ThumbnailStrip extends StatelessWidget {
  const _ThumbnailStrip({required this.controller});

  final BagMediaViewerController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppDimensions.bagThumbnailSize,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingMd),
        itemCount: controller.media.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppDimensions.spacingSm),
        itemBuilder: (context, index) => _ThumbnailTile(controller: controller, index: index),
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
        child: Container(
          width: AppDimensions.bagThumbnailSize,
          height: AppDimensions.bagThumbnailSize,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            border: Border.all(
              color: selected ? AppColors.primaryLight : Colors.transparent,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm - 2),
            child: item.type == BagMediaType.image
                ? CachedNetworkImage(imageUrl: item.url, fit: BoxFit.cover)
                : ColoredBox(
                    color: AppColors.textPrimary,
                    child: const Icon(Icons.play_circle_outline, color: AppColors.surface),
                  ),
          ),
        ),
      );
    });
  }
}
