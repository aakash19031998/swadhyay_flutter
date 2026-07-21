import 'package:get/get.dart';

import '../controllers/bag_media_viewer_args.dart';
import '../controllers/bag_media_viewer_controller.dart';

class BagMediaViewerBinding extends Bindings {
  @override
  void dependencies() {
    final BagMediaViewerArgs args = Get.arguments as BagMediaViewerArgs;
    Get.put(BagMediaViewerController(media: args.media, initialIndex: args.initialIndex));
  }
}
