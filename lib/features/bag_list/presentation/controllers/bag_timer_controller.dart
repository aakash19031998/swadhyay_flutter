import 'dart:async';

import 'package:get/get.dart';

enum BagWorkStatus { notStarted, running, paused, done }

/// Drives one bag's productivity clock and Start/Pause/Resume/Done
/// workflow. Kept as its own GetX controller (tagged by bag id) instead of
/// living on [BagEntity] so restarting the clock never depends on
/// re-fetching the bag list.
class BagTimerController extends GetxController {
  /// The single source of truth for [bagId]'s timer: finds the tagged
  /// instance if one already exists (e.g. Bag List already started it) or
  /// creates it. [BagListItem] and [BagDetailController] both go through
  /// this instead of duplicating the find-or-create lookup, so Start /
  /// Pause / Resume / Done performed on either screen always act on the
  /// exact same instance and stay in sync — including across navigation,
  /// since it's registered without a route-scoped binding and so is never
  /// disposed on `Get.back()`.
  static BagTimerController of(String bagId) {
    if (Get.isRegistered<BagTimerController>(tag: bagId)) {
      return Get.find<BagTimerController>(tag: bagId);
    }
    return Get.put(BagTimerController(), tag: bagId);
  }

  final Rx<BagWorkStatus> status = BagWorkStatus.notStarted.obs;
  final Rx<Duration> elapsed = Duration.zero.obs;
  final Rxn<String> pauseReason = Rxn<String>();

  Timer? _ticker;

  void start() => _resumeFrom(BagWorkStatus.running);

  void resume() {
    pauseReason.value = null;
    _resumeFrom(BagWorkStatus.running);
  }

  void pause({String? reason}) {
    _ticker?.cancel();
    pauseReason.value = reason;
    status.value = BagWorkStatus.paused;
  }

  void done() {
    _ticker?.cancel();
    status.value = BagWorkStatus.done;
  }

  void _resumeFrom(BagWorkStatus next) {
    status.value = next;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed.value += const Duration(seconds: 1);
    });
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }
}
