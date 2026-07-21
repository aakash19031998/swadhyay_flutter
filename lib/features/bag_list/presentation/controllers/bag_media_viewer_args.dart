import '../../domain/entities/bag_media_entity.dart';

/// Navigation payload for `Get.toNamed(AppRoutes.bagMediaViewer, ...)` — this
/// screen has no data source of its own, it only ever displays media
/// already loaded with the bag.
class BagMediaViewerArgs {
  const BagMediaViewerArgs({required this.media, this.initialIndex = 0});

  final List<BagMediaEntity> media;
  final int initialIndex;
}
