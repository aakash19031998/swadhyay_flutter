import 'package:get/get.dart';

import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/earn_till_date_data_source.dart';
import '../../data/datasources/earn_till_date_mock_data_source_impl.dart';
import '../../data/repositories/earn_till_date_repository_impl.dart';
import '../../domain/repositories/earn_till_date_repository.dart';
import '../../domain/usecases/get_earn_till_date_usecase.dart';
import '../controllers/earn_till_date_controller.dart';

class EarnTillDateBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    // No real backend yet — always the mock data source (see
    // EarnTillDateDataSource's own doc comment). Swapping in a live one
    // later is a one-line change here, same as every other mock feature in
    // this app.
    Get.lazyPut<EarnTillDateDataSource>(() => EarnTillDateMockDataSourceImpl());
    Get.lazyPut<EarnTillDateRepository>(
      () => EarnTillDateRepositoryImpl(Get.find<EarnTillDateDataSource>()),
    );
    Get.lazyPut<GetEarnTillDateUseCase>(
      () => GetEarnTillDateUseCase(Get.find<EarnTillDateRepository>()),
    );
    Get.lazyPut<EarnTillDateController>(
      () => EarnTillDateController(
        Get.find<GetEarnTillDateUseCase>(),
        Get.find<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
