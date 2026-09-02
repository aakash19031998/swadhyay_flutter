import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/helpers/suggestion_helper.dart' as suggestion_helper;
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/usecases/get_bag_media_usecase.dart';
import '../../domain/usecases/get_bags_usecase.dart';
import '../../domain/usecases/track_no_work_usecase.dart';
import 'bag_media_viewer_args.dart';

class BagListController extends ListStateController<BagEntity> {
  BagListController(
    this._getBagsUseCase,
    this._getCurrentEmployeeUseCase,
    this._getBagMediaUseCase,
    this._trackNoWorkUseCase,
  );

  final GetBagsUseCase _getBagsUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final GetBagMediaUseCase _getBagMediaUseCase;
  final TrackNoWorkUseCase _trackNoWorkUseCase;

  /// Backs the search field so a scanned barcode/QR value can be shown in
  /// the field itself (not just applied as a silent filter).
  final TextEditingController searchController = TextEditingController();

  /// `IssuedBagListNew`'s own totals for the full (unfiltered) bag list —
  /// shown on the app bar's counter pills. Populated by [fetch] on every
  /// load, straight from the server response.
  final RxInt bagCount = 0.obs;
  final RxInt pcsCount = 0.obs;

  /// Drives the "No Work" button: hidden until the first successful load,
  /// then follows `data.no_work_status` on every subsequent load. Always
  /// enabled when shown — no disabled/faded state.
  final RxBool noWorkVisible = false.obs;

  /// True when `data.no_work_status == "Y"` and `data.no_work_running ==
  /// "S"` — a no-work session is currently running (either already, from
  /// the server's own state, or because this session's own tap just
  /// started one). Drives the "Your No Work Time is started" indicator
  /// shown to the left of the bag count.
  final RxBool noWorkRunning = false.obs;

  String? _empCd;

  /// Full (unfiltered) snapshot from the last successful load. `query` is
  /// applied to this purely in-memory — `IssuedBagListNew` has no
  /// server-side search of its own, and re-fetching the whole list over
  /// the network on every keystroke (the original approach) opened a race:
  /// typing fast, or picking a suggestion right after typing, could fire
  /// two overlapping requests, and whichever happened to resolve last —
  /// not necessarily the most recent one — would silently overwrite the
  /// list, so a selected result could get clobbered by a stale response.
  /// Filtering client-side against this snapshot removes the network call
  /// (and the race) from search entirely.
  List<BagEntity> _allBags = const [];

  @override
  Future<Either<Failure, List<BagEntity>>> fetch(String searchQuery) async {
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;

    final result = await _getBagsUseCase(empCd: _empCd ?? '');
    return result.fold(
      (failure) => Left(failure),
      (data) {
        bagCount.value = data.bagCount;
        pcsCount.value = data.pcsCount;
        noWorkVisible.value = data.noWorkStatus == 'Y';
        noWorkRunning.value = data.noWorkStatus == 'Y' && data.noWorkRunning == 'S';
        _allBags = data.bags;
        // Filters by the *current* query.value, not the searchQuery this
        // call started with — this network fetch can take a while (see
        // AppConfig.receiveTimeout), and if a scan or a keystroke changes
        // the search text while it's still in flight (onQueryChanged
        // applies instantly, no network involved), this call must not
        // resolve later and clobber that newer result with a stale one.
        return Right(_filter(query.value));
      },
    );
  }

  List<BagEntity> _filter(String query) {
    final String needle = query.trim().toLowerCase();
    if (needle.isEmpty) return _allBags;
    return _allBags
        .where((bag) => bag.bagNo.toLowerCase().contains(needle) || bag.designNo.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  /// Re-filters the already-loaded [_allBags] snapshot in place — no
  /// network call, so there's nothing for a fast search to race against.
  @override
  void onQueryChanged(String value) {
    query.value = value;
    items.assignAll(_filter(value));
  }

  /// Distinct bag/design numbers containing [text], drawn from the full
  /// [_allBags] snapshot (refreshed on every explicit load/refresh) — not
  /// narrowed by whatever's already typed, and never a stale/separately
  /// cached list, so a bag that's no longer in the list (completed,
  /// removed, etc.) can never still show up as a suggestion.
  List<String> suggestionsFor(String text) {
    return suggestion_helper.suggestionsFor(text, _allBags, [
      (BagEntity bag) => bag.bagNo,
      (BagEntity bag) => bag.designNo,
    ]);
  }

  void onBagDone(BagEntity bag) {
    Get.toNamed(AppRoutes.bagCompletion, arguments: bag);
  }

  /// Fetches this bag's image/video gallery from `ImageAndVideoUrls` (using
  /// its design/style number as `styleCd` — the list screen has no other
  /// design identifier available yet) and opens the shared media viewer,
  /// same screen the Design Master screen also opens. Unlike the old
  /// mock-only `bag.media` list, this is a fresh network call per tap, so a
  /// blocking loader covers the wait.
  Future<void> openMediaGallery(BagEntity bag) async {
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;

    AppDialog.loading();
    final result = await _getBagMediaUseCase(empCd: _empCd ?? '', styleCd: bag.designNo);
    AppDialog.dismiss();

    result.fold(
      AppSnackbar.showFailure,
      (media) {
        if (media.isEmpty) {
          AppSnackbar.show(
            title: AppStrings.alertWarning,
            message: AppStrings.noMediaFound,
            isSuccess: false,
          );
          return;
        }
        Get.toNamed(AppRoutes.bagMediaViewer, arguments: BagMediaViewerArgs(media: media));
      },
    );
  }

  void onScanned(String value) {
    searchController.text = value;
    onQueryChanged(value);
  }

  /// Calls `BagTimeTracking` with `action: "N"` — the same endpoint
  /// Start/Pause/Resume use (see `TrackBagTimeUseCase`), but via the
  /// dedicated [TrackNoWorkUseCase] call shape, which sends only `action`
  /// and `empCd` (none of that endpoint's other fields apply here).
  Future<void> onNoWorkTap() async {
    _empCd ??= (await _getCurrentEmployeeUseCase())?.empCode;

    AppDialog.loading();
    final result = await _trackNoWorkUseCase(empCd: int.tryParse(_empCd ?? '') ?? 0);
    AppDialog.dismiss();

    result.fold(
      AppSnackbar.showFailure,
      (response) {
        if (response.success) noWorkRunning.value = true;
        if (response.message.isNotEmpty) {
          AppSnackbar.show(
            title: response.success ? AppStrings.success : AppStrings.alertWarning,
            message: response.message,
            isSuccess: response.success,
          );
        }
      },
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
