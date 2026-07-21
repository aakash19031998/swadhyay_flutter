import 'package:get/get.dart';

import '../../domain/entities/bag_entity.dart';
import '../controllers/bag_completion_controller.dart';

class BagCompletionBinding extends Bindings {
  @override
  void dependencies() {
    final BagEntity bag = Get.arguments as BagEntity;
    Get.put(BagCompletionController(bag));
  }
}
