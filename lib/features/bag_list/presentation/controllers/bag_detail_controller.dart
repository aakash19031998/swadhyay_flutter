import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_dialog.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/usecases/get_bag_detail_usecase.dart';
import '../../domain/usecases/get_bag_media_usecase.dart';
import 'bag_media_viewer_args.dart';
import 'bag_timer_controller.dart';

/// Drives the bag detail screen: which of the two summary tabs is active,
/// the Start/Pause/Resume/Done actions for that bag's productivity clock,
/// and — on open — fetching `BagDetailsNew`'s Bag Summary/Manufacturing
/// Instructions data and merging it onto the [BagEntity] the list screen
/// already passed in (see [BagEntity.copyWith]). [bag] starts out with
/// whatever the list screen knew and is refined in place once that fetch
/// resolves, so the screen is fully usable immediately and just fills in
/// the rest shortly after.
class BagDetailController extends GetxController with GetSingleTickerProviderStateMixin {
  BagDetailController(
    BagEntity initialBag,
    this._getBagDetailUseCase,
    this._getCurrentEmployeeUseCase,
    this._getBagMediaUseCase,
  ) : bag = Rx<BagEntity>(initialBag);

  final GetBagDetailUseCase _getBagDetailUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;
  final GetBagMediaUseCase _getBagMediaUseCase;

  final Rx<BagEntity> bag;

  /// True while the `BagDetailsNew` fetch is in flight — drives [AppLoader]
  /// in place of the Bag Summary/Manufacturing Instructions content until
  /// that data has actually been bound onto [bag].
  final RxBool isLoading = true.obs;

  late final TabController tabController = TabController(length: 2, vsync: this);

  late final BagTimerController timer = BagTimerController.of(bag.value);

  @override
  void onInit() {
    super.onInit();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    isLoading.value = true;
    try {
      final String? empCd = (await _getCurrentEmployeeUseCase())?.empCode;
      final result = await _getBagDetailUseCase(bagNo: bag.value.bagNo, empCd: empCd ?? '');
      result.fold(
        (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
        (detail) {
          bag.value = bag.value.copyWith(
            delDate: detail.delDate,
            bagQty: detail.bagQty,
            styleNo: detail.styleNo,
            locationCode: detail.orderNo,
            customer: detail.customer,
            part: detail.part,
            size: detail.size,
            designCategory: detail.designCategory,
            metal: detail.metal,
            designGrossWt: detail.designGrossWt,
            designNetWt: detail.designNetWt,
            designInstr: detail.designInstr,
            custInstr: detail.custInstr,
            stampInstr: detail.stampInstr,
            rhodInstr: detail.rhodInstr,
            diamInstr: detail.diamInstr,
            byy: detail.byy,
            bchr: detail.bchr,
            bno: detail.bno,
            bagCmpCd: detail.bagCmpCd,
            diamondDetails: detail.diamondDetails,
            rmSummary: detail.rmSummary,
            sizeInstr: detail.sizeInstr,
          );
        },
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() => Get.back<void>();

  /// Fetches this bag's image/video gallery from `ImageAndVideoUrls` and
  /// opens the same shared media viewer the Bag List screen's thumbnail and
  /// the Design Master screen's image card both open — same API call,
  /// same `styleCd` (the design number), same behavior everywhere.
  Future<void> openMediaGallery() async {
    final String? empCd = (await _getCurrentEmployeeUseCase())?.empCode;

    AppDialog.loading();
    final result = await _getBagMediaUseCase(empCd: empCd ?? '', styleCd: bag.value.designNo);
    AppDialog.dismiss();

    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (media) {
        if (media.isEmpty) {
          Get.snackbar(AppStrings.somethingWentWrong, AppStrings.noMediaFound);
          return;
        }
        Get.toNamed(AppRoutes.bagMediaViewer, arguments: BagMediaViewerArgs(media: media));
      },
    );
  }

  void onDone() {
    Get.toNamed(AppRoutes.bagCompletion, arguments: bag.value);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
