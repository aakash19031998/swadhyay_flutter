import 'package:get/get.dart';

import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../domain/entities/earn_till_date_entity.dart';
import '../../domain/usecases/get_earn_till_date_usecase.dart';

/// Drives the Earn Till Date screen — the signed-in employee's own
/// record (profile + stat cards + the full ticked-field table), fetched
/// once on open. Placeholder data only — see
/// `EarnTillDateDataSource`'s own doc comment.
class EarnTillDateController extends GetxController {
  EarnTillDateController(
    this._getEarnTillDateUseCase,
    this._getCurrentEmployeeUseCase,
  );

  final GetEarnTillDateUseCase _getEarnTillDateUseCase;
  final GetCurrentEmployeeUseCase _getCurrentEmployeeUseCase;

  final Rxn<EarnTillDateEntity> details = Rxn<EarnTillDateEntity>();
  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;

    final employee = await _getCurrentEmployeeUseCase();
    final result = await _getEarnTillDateUseCase(
      empCd: employee?.empCode ?? '',
      empName: employee?.name ?? '',
    );
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (data) => details.value = data,
    );
    isLoading.value = false;
  }
}
