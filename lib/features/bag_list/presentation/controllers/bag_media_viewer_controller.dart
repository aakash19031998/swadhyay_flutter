import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../domain/entities/bag_media_entity.dart';

/// Drives the full-screen media viewer: which page is showing, the
/// thumbnail strip's selection, and the lifecycle of the single active
/// [VideoPlayerController] (only the on-screen video is ever initialized,
/// never the whole gallery at once).
class BagMediaViewerController extends GetxController {
  BagMediaViewerController({required this.media, required int initialIndex})
      : currentIndex = initialIndex.obs,
        pageController = PageController(initialPage: initialIndex);

  final List<BagMediaEntity> media;
  final RxInt currentIndex;
  final PageController pageController;

  final Rxn<VideoPlayerController> videoController = Rxn<VideoPlayerController>();
  final RxBool isVideoReady = false.obs;
  final RxBool isVideoPlaying = false.obs;

  /// Set when `initialize()` throws or times out — e.g. the server not
  /// supporting the byte-range requests video streaming needs. Previously
  /// this had no error handling at all: a failed `initialize()` left
  /// [isVideoReady] `false` forever with nothing to show but the loading
  /// spinner, indistinguishable from "still loading".
  final RxBool hasVideoError = false.obs;

  /// True while the current image page is pinch/double-tap zoomed in past
  /// 1x — the [PageView] disables its own swipe physics while this is true
  /// (see `BagMediaViewerView`), so panning around a zoomed-in image never
  /// fights the gesture arena against swiping to the next/previous page.
  final RxBool isZoomed = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVideoIfNeeded(currentIndex.value);
  }

  void setZoomed(bool value) => isZoomed.value = value;

  void onPageChanged(int index) {
    currentIndex.value = index;
    isZoomed.value = false;
    _disposeVideo();
    _loadVideoIfNeeded(index);
  }

  void selectThumbnail(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void toggleVideoPlayback() {
    final VideoPlayerController? player = videoController.value;
    if (player == null) return;
    if (player.value.isPlaying) {
      player.pause();
    } else {
      player.play();
    }
  }

  /// Retries loading the current page's video after [hasVideoError] — the
  /// error state doesn't clear itself, so the view offers an explicit retry
  /// action instead of being stuck.
  void retryVideo() {
    _disposeVideo();
    _loadVideoIfNeeded(currentIndex.value);
  }

  Future<void> _loadVideoIfNeeded(int index) async {
    final BagMediaEntity item = media[index];
    if (item.type != BagMediaType.video) return;

    final VideoPlayerController player = VideoPlayerController.networkUrl(Uri.parse(item.url));
    videoController.value = player;
    isVideoReady.value = false;
    isVideoPlaying.value = false;
    hasVideoError.value = false;
    player.addListener(_onVideoTick);

    try {
      await player.initialize().timeout(const Duration(seconds: 20));
      if (videoController.value != player) return;
      isVideoReady.value = true;
      await player.play();
    } catch (_) {
      if (videoController.value != player) return;
      hasVideoError.value = true;
    }
  }

  void _onVideoTick() {
    final VideoPlayerController? player = videoController.value;
    if (player == null) return;
    isVideoPlaying.value = player.value.isPlaying;
  }

  void _disposeVideo() {
    final VideoPlayerController? player = videoController.value;
    player?.removeListener(_onVideoTick);
    player?.dispose();
    videoController.value = null;
    isVideoReady.value = false;
    isVideoPlaying.value = false;
    hasVideoError.value = false;
  }

  @override
  void onClose() {
    _disposeVideo();
    pageController.dispose();
    super.onClose();
  }
}
