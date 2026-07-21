import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/skipped_bag_entity.dart';
import '../../domain/usecases/get_skipped_bags_usecase.dart';
import '../../domain/usecases/skip_bag_usecase.dart';

/// Owns both the skip-bag form and the reactive skip-history list below it
/// (the history reuses [ListStateController] since it's the same
/// search/loading/empty/error shape as every other report screen).
class SkipBagController extends ListStateController<SkippedBagEntity> {
  SkipBagController(this._getSkippedBagsUseCase, this._skipBagUseCase);

  final GetSkippedBagsUseCase _getSkippedBagsUseCase;
  final SkipBagUseCase _skipBagUseCase;

  static const List<String> reasons = ['Damaged', 'Missing Stone', 'Wrong Design', 'Other'];

  final formKey = GlobalKey<FormState>();
  final bagNumberController = TextEditingController();
  final Rx<String> selectedReason = reasons.first.obs;
  final RxBool isSubmitting = false.obs;

  @override
  Future<Either<Failure, List<SkippedBagEntity>>> fetch(String searchQuery) {
    return _getSkippedBagsUseCase(query: searchQuery);
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isSubmitting.value = true;
    final result = await _skipBagUseCase(
      SkipBagParams(bagNo: bagNumberController.text.trim(), reason: selectedReason.value),
    );
    isSubmitting.value = false;

    result.fold(
      (failure) => Get.snackbar(AppStrings.somethingWentWrong, failure.message),
      (_) {
        Get.snackbar(AppStrings.skipBagAction, AppStrings.bagSkippedSuccess);
        bagNumberController.clear();
        load();
      },
    );
  }

  @override
  void onClose() {
    bagNumberController.dispose();
    super.onClose();
  }
}
