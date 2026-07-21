import 'package:get/get.dart';

import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_detail_controller.dart';

class BagDetailBinding extends Bindings {
  @override
  void dependencies() {
    final BagEntity bag = Get.arguments as BagEntity;
    Get.put(BagDetailController(bag));
  }
}
