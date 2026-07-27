import 'package:get/get.dart';

import '../controllers/bag_scanner_controller.dart';

class BagScannerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BagScannerController());
  }
}
