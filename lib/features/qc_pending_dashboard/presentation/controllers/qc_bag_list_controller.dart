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
import '../../../bag_list/domain/usecases/get_bag_media_usecase.dart';
import '../../../bag_list/presentation/controllers/bag_media_viewer_args.dart';
import '../../domain/entities/qc_assigned_bag_entity.dart';
import '../../domain/usecases/get_qc_assigned_bags_usecase.dart';

/// Drives the "QC Bag List" screen opened from one employee's [QcCheckCard]
/// — the bags currently in that employee's QC queue. Same "load once,
/// filter locally" search shape as `BagListController`/`QcPendingDashboardController`.
class QcBagListController extends ListStateController<QcAssignedBagEntity> {
  QcBagListController(
    this._getQcAssignedBagsUseCase,
    this._getBagMediaUseCase, {
    required this.empCode,
    required this.empName,
    required this.totalBags,
    required this.totalPieces,
    this.imageUrl,
  });

  final GetQcAssignedBagsUseCase _getQcAssignedBagsUseCase;
  final GetBagMediaUseCase _getBagMediaUseCase;
  final String empCode;
  final String empName;
  final int totalBags;
  final int totalPieces;
  final String? imageUrl;

  /// Backs the search field so a scanned barcode/QR value can be shown in
  /// the field itself (not just applied as a silent filter) — same as
  /// Bag List's own search field.
  final TextEditingController searchController = TextEditingController();

  List<QcAssignedBagEntity> _allBags = const [];

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  List<QcAssignedBagEntity> _filter(String value) {
    final String needle = value.trim().toLowerCase();
    if (needle.isEmpty) return _allBags;
    return _allBags
        .where(
          (bag) =>
              bag.bagNo.toLowerCase().contains(needle) ||
              bag.orderNo.toLowerCase().contains(needle) ||
              bag.style.toLowerCase().contains(needle),
        )
        .toList(growable: false);
  }

  @override
  void onQueryChanged(String value) {
    query.value = value;
    items.assignAll(_filter(value));
  }

  void onScanned(String value) {
    searchController.text = value;
    onQueryChanged(value);
  }

  List<String> suggestionsFor(String text) {
    return suggestion_helper.suggestionsFor(text, _allBags, [
      (QcAssignedBagEntity bag) => bag.bagNo,
      (QcAssignedBagEntity bag) => bag.orderNo,
    ]);
  }

  @override
  Future<Either<Failure, List<QcAssignedBagEntity>>> fetch(
    String searchQuery,
  ) async {
    final result = await _getQcAssignedBagsUseCase(empCode: empCode);
    return result.fold((failure) => Left(failure), (list) {
      _allBags = list;
      return Right(_filter(query.value));
    });
  }

  /// Fetches this bag's image/video gallery from `ImageAndVideoUrls` (using
  /// the bag's own `style` as `styleCd`, and this screen's already-selected
  /// employee as `empCd`) and opens the shared media viewer — same screen
  /// Bag List/Design Master also open. A fresh network call per tap, so a
  /// blocking loader covers the wait.
  Future<void> openBagMedia(QcAssignedBagEntity bag) async {
    AppDialog.loading();
    final result = await _getBagMediaUseCase(
      empCd: empCode,
      styleCd: bag.style,
    );
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
        Get.toNamed(
          AppRoutes.bagMediaViewer,
          arguments: BagMediaViewerArgs(media: media),
        );
      },
    );
  }
}
