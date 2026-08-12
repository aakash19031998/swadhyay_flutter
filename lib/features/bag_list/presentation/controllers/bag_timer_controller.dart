import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/entities/pause_reason_entity.dart';
import '../../domain/usecases/track_bag_time_usecase.dart';
import '../widgets/pause_reason_dialog.dart';

enum BagWorkStatus { notStarted, running, paused, done }

/// Drives one bag's productivity clock and Start/Pause/Resume/Done
/// workflow. Kept as its own GetX controller (tagged by bag id) instead of
/// living on [BagEntity] so restarting the clock never depends on
/// re-fetching the bag list.
///
/// Start/Pause/Resume each call `BagTimeTracking` first — [status] only
/// actually flips (and the ticker only starts/stops) once the response
/// comes back with a truthy `status`; a `false`/failed response leaves the
/// clock exactly as it was, so the Start/Pause/Resume/Done buttons
/// (switched on [status] in `BagListItem`/`BagDetailView`) never show a
/// state the backend didn't actually confirm. The response's `message` is
/// always shown via snackbar, success or not.
class BagTimerController extends GetxController {
  /// The single source of truth for [bag]'s timer: finds the tagged
  /// instance if one already exists (e.g. Bag List already started it) or
  /// creates it. [BagListItem] and [BagDetailController] both go through
  /// this instead of duplicating the find-or-create lookup, so Start /
  /// Pause / Resume / Done performed on either screen always act on the
  /// exact same instance and stay in sync — including across navigation,
  /// since it's registered without a route-scoped binding and so is never
  /// disposed on `Get.back()`.
  ///
  /// [BagEntity.spStatus]/[BagEntity.seconds] (from `IssuedBagListNew`)
  /// only seed the timer's initial state on that first creation — every
  /// later call (a pull-to-refresh handing back a fresh `BagEntity`, or
  /// simply reopening the bag) just finds the already-registered instance
  /// and leaves it exactly as the user's own Start/Pause/Resume actions
  /// have already left it, never resetting a live timer back to a stale
  /// server snapshot.
  static BagTimerController of(BagEntity bag) {
    if (Get.isRegistered<BagTimerController>(tag: bag.id)) {
      return Get.find<BagTimerController>(tag: bag.id);
    }
    final BagTimerController controller = BagTimerController();
    controller._seed(spStatus: bag.spStatus, seconds: bag.seconds);
    return Get.put(controller, tag: bag.id);
  }

  final Rx<BagWorkStatus> status = BagWorkStatus.notStarted.obs;
  final Rx<Duration> elapsed = Duration.zero.obs;
  final Rxn<String> pauseReason = Rxn<String>();

  /// True while a Start/Pause/Resume call is in flight — the calling
  /// screen disables the action button on this so a slow response can't be
  /// triggered twice.
  final RxBool isProcessing = false.obs;

  Timer? _ticker;

  Future<void> start(BagEntity bag) async {
    await _track(bag: bag, action: 'S', onSuccess: () => _resumeFrom(BagWorkStatus.running));
  }

  Future<void> resume(BagEntity bag) async {
    await _track(
      bag: bag,
      action: 'R',
      onSuccess: () {
        pauseReason.value = null;
        _resumeFrom(BagWorkStatus.running);
      },
    );
  }

  /// Prompts for a reason (via [PauseReasonDialog]) before calling the
  /// API — cancelling the dialog leaves everything untouched, no call is
  /// made.
  Future<void> pause(BagEntity bag) async {
    final PauseReasonEntity? reason = await PauseReasonDialog.show();
    if (reason == null) return;

    await _track(
      bag: bag,
      action: 'P',
      pauseReasonId: reason.reasonId,
      onSuccess: () {
        _ticker?.cancel();
        pauseReason.value = reason.reasonDesc;
        status.value = BagWorkStatus.paused;
      },
    );
  }

  void done() {
    _ticker?.cancel();
    status.value = BagWorkStatus.done;
  }

  /// Applies `IssuedBagListNew`'s `SPStatus`/`Seconds` — called once, only
  /// from [of]'s creation branch. `spStatus` names the bag's current
  /// state directly (not an action to perform, and *not* the same letters
  /// as `BagTimeTracking`'s own `action` field, despite the overlap).
  ///
  /// `seconds` gates everything first: with no elapsed time recorded yet
  /// (`seconds <= 0`), the bag always shows Start with the timer stopped,
  /// no matter what `spStatus` says. Only once `seconds > 0` does
  /// `spStatus` decide between "R"/"S" -> running (show Pause + Done, timer
  /// started immediately so the clock is live, not frozen) and "P" ->
  /// paused (show Resume + Done, timer stopped).
  void _seed({required String? spStatus, required int? seconds}) {
    final int elapsedSeconds = seconds ?? 0;
    elapsed.value = Duration(seconds: elapsedSeconds);

    if (elapsedSeconds <= 0) {
      status.value = BagWorkStatus.notStarted;
      return;
    }

    switch (spStatus) {
      case 'R':
      case 'S':
        _resumeFrom(BagWorkStatus.running);
      case 'P':
      default:
        status.value = BagWorkStatus.paused;
    }
  }

  Future<void> _track({
    required BagEntity bag,
    required String action,
    required VoidCallback onSuccess,
    int? pauseReasonId,
  }) async {
    if (isProcessing.value) return;
    isProcessing.value = true;
    try {
      final String? empCode = (await Get.find<GetCurrentEmployeeUseCase>()())?.empCode;
      final result = await Get.find<TrackBagTimeUseCase>()(
        action: action,
        transactionId: int.tryParse(bag.id) ?? 0,
        bCoCo: bag.bagCmpCd ?? '',
        byy: bag.byy ?? '',
        bchr: bag.bchr ?? '',
        bNo: bag.bno ?? 0,
        empCd: int.tryParse(empCode ?? '') ?? 0,
        pauseReasonId: pauseReasonId,
      );

      result.fold(
        (failure) => AppSnackbar.show(
          title: AppStrings.alertWarning,
          message: failure.message,
          isSuccess: false,
        ),
        (response) {
          if (response.message.isNotEmpty) {
            AppSnackbar.show(
              title: response.success ? AppStrings.success : AppStrings.alertWarning,
              message: response.message,
              isSuccess: response.success,
            );
          }
          if (response.success) onSuccess();
        },
      );
    } finally {
      isProcessing.value = false;
    }
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
