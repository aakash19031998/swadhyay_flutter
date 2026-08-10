import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../domain/entities/design_master_entity.dart';
import '../../domain/usecases/get_design_master_usecase.dart';

/// Drives the Design Master (Design Image) screen: nothing is fetched until
/// [search] is called with a style number, so the screen starts out showing
/// only the search bar (see `DesignImageView`).
class DesignImageController extends GetxController with GetSingleTickerProviderStateMixin {
  DesignImageController(this._getDesignMasterUseCase);

  final GetDesignMasterUseCase _getDesignMasterUseCase;

  final RxBool isLoading = false.obs;
  final RxBool hasSearched = false.obs;
  final Rxn<DesignMasterEntity> result = Rxn<DesignMasterEntity>();

  late final TabController tabController = TabController(length: 4, vsync: this);

  Future<void> search(String styleNo) async {
    if (styleNo.trim().isEmpty) {
      Get.snackbar(AppStrings.somethingWentWrong, AppStrings.designMasterEnterStyleNo);
      return;
    }

    hasSearched.value = true;
    isLoading.value = true;
    result.value = null;
    tabController.index = 0;

    final outcome = await _getDesignMasterUseCase(styleNo: styleNo.trim());
    outcome.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (design) => result.value = design,
    );
    isLoading.value = false;
  }

  /// Clears back to the initial "nothing searched yet" state — used when the
  /// search field's clear (✕) button is tapped, distinct from [search] which
  /// validates and fetches.
  void reset() {
    hasSearched.value = false;
    result.value = null;
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}
