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

  @override
  void onInit() {
    super.onInit();
    _loadVideoIfNeeded(currentIndex.value);
  }

  void onPageChanged(int index) {
    currentIndex.value = index;
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

  Future<void> _loadVideoIfNeeded(int index) async {
    final BagMediaEntity item = media[index];
    if (item.type != BagMediaType.video) return;

    final VideoPlayerController player = VideoPlayerController.networkUrl(Uri.parse(item.url));
    videoController.value = player;
    isVideoReady.value = false;
    isVideoPlaying.value = false;
    player.addListener(_onVideoTick);

    await player.initialize();
    if (videoController.value != player) return;
    isVideoReady.value = true;
    await player.play();
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
  }

  @override
  void onClose() {
    _disposeVideo();
    pageController.dispose();
    super.onClose();
  }
}
