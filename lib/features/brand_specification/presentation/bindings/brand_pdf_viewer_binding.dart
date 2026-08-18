import 'package:get/get.dart';

import '../controllers/brand_pdf_viewer_args.dart';
import '../controllers/brand_pdf_viewer_controller.dart';

class BrandPdfViewerBinding extends Bindings {
  @override
  void dependencies() {
    final BrandPdfViewerArgs args = Get.arguments as BrandPdfViewerArgs;
    Get.put(BrandPdfViewerController(url: args.url, title: args.title));
  }
}
