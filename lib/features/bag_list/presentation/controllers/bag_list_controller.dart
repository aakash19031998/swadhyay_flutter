import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/usecases/get_bags_usecase.dart';

class BagListController extends ListStateController<BagEntity> {
  BagListController(this._getBagsUseCase, this._getCurrentEmployeeUseCase);

  final GetBagsUseCase _getBagsUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  /// Backs the search field so a scanned barcode/QR value can be shown in
  /// the field itself (not just applied as a silent filter).
  final TextEditingController searchController = TextEditingController();

  /// `IssuedBagListNew`'s own totals for the full (unfiltered) bag list —
  /// shown on the app bar's counter pills. Populated by [fetch] on every
  /// load, straight from the server response.
  final RxInt bagCount = 0.obs;
  final RxInt pcsCount = 0.obs;

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
    final String needle = text.trim().toLowerCase();
    if (needle.isEmpty) return const [];

    final List<String> matches = [];
    for (final bag in _allBags) {
      if (bag.bagNo.toLowerCase().contains(needle) && !matches.contains(bag.bagNo)) {
        matches.add(bag.bagNo);
      }
      if (bag.designNo.toLowerCase().contains(needle) && !matches.contains(bag.designNo)) {
        matches.add(bag.designNo);
      }
    }
    return matches.take(8).toList(growable: false);
  }

  void onBagDone(BagEntity bag) {
    Get.toNamed(AppRoutes.bagCompletion, arguments: bag);
  }

  void onScanned(String value) {
    searchController.text = value;
    onQueryChanged(value);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
