import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/bag_entity.dart';
import 'bag_timer_controller.dart';

/// Drives the bag detail screen: which of the two summary tabs is active,
/// and the "Back / Pause" action, which pauses that bag's productivity
/// clock (started from [BagListItem]) before leaving the screen.
class BagDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  BagDetailController(this.bag);

  final BagEntity bag;

  late final TabController tabController = TabController(length: 2, vsync: this);

  void pauseAndGoBack() {
    final BagTimerController? timer = _timer;
    if (timer != null && timer.status.value == BagWorkStatus.running) timer.pause();
    Get.back();
  }

  void onDone() {
    _timer?.done();
    Get.toNamed(AppRoutes.bagCompletion, arguments: bag);
  }

  /// Exposed so the view can show a live running clock in the top bar —
  /// null if this bag's timer was never started from the list screen.
  BagTimerController? get timer => _timer;

  BagTimerController? get _timer =>
      Get.isRegistered<BagTimerController>(tag: bag.id) ? Get.find<BagTimerController>(tag: bag.id) : null;

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
