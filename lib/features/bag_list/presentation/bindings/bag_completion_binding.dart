import 'package:get/get.dart';

import '../../../../core/network/api_client.dart';
import '../../../authentication/di/auth_dependencies.dart';
import '../../../authentication/domain/repositories/auth_repository.dart';
import '../../../authentication/domain/usecases/get_current_employee_usecase.dart';
import '../../data/datasources/bag_completion_master_data_source.dart';
import '../../data/datasources/bag_completion_master_remote_data_source_impl.dart';
import '../../data/datasources/bag_done_submit_data_source.dart';
import '../../data/datasources/bag_done_submit_remote_data_source_impl.dart';
import '../../data/datasources/dummy_add_btn_validation_data_source.dart';
import '../../data/datasources/dummy_add_btn_validation_remote_data_source_impl.dart';
import '../../data/datasources/sub_work_type_data_source.dart';
import '../../data/datasources/sub_work_type_remote_data_source_impl.dart';
import '../../data/repositories/bag_completion_master_repository_impl.dart';
import '../../data/repositories/bag_done_submit_repository_impl.dart';
import '../../data/repositories/dummy_add_btn_validation_repository_impl.dart';
import '../../data/repositories/sub_work_type_repository_impl.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/repositories/bag_completion_master_repository.dart';
import '../../domain/repositories/bag_done_submit_repository.dart';
import '../../domain/repositories/dummy_add_btn_validation_repository.dart';
import '../../domain/repositories/sub_work_type_repository.dart';
import '../../domain/usecases/get_bag_completion_master_usecase.dart';
import '../../domain/usecases/get_sub_work_types_usecase.dart';
import '../../domain/usecases/submit_bag_done_usecase.dart';
import '../../domain/usecases/validate_add_btn_usecase.dart';
import '../controllers/bag_completion_controller.dart';

class BagCompletionBinding extends Bindings {
  @override
  void dependencies() {
    AuthDependencies.ensureRegistered();

    final BagEntity bag = Get.arguments as BagEntity;

    Get.lazyPut<GetCurrentEmployeeUseCase>(() => GetCurrentEmployeeUseCase(Get.find<AuthRepository>()));

    Get.lazyPut<BagCompletionMasterDataSource>(
      () => BagCompletionMasterRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagCompletionMasterRepository>(
      () => BagCompletionMasterRepositoryImpl(Get.find<BagCompletionMasterDataSource>()),
    );
    Get.lazyPut<GetBagCompletionMasterUseCase>(
      () => GetBagCompletionMasterUseCase(Get.find<BagCompletionMasterRepository>()),
    );

    Get.lazyPut<SubWorkTypeDataSource>(
      () => SubWorkTypeRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<SubWorkTypeRepository>(
      () => SubWorkTypeRepositoryImpl(Get.find<SubWorkTypeDataSource>()),
    );
    Get.lazyPut<GetSubWorkTypesUseCase>(
      () => GetSubWorkTypesUseCase(Get.find<SubWorkTypeRepository>()),
    );

    Get.lazyPut<DummyAddBtnValidationDataSource>(
      () => DummyAddBtnValidationRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<DummyAddBtnValidationRepository>(
      () => DummyAddBtnValidationRepositoryImpl(Get.find<DummyAddBtnValidationDataSource>()),
    );
    Get.lazyPut<ValidateAddBtnUseCase>(
      () => ValidateAddBtnUseCase(Get.find<DummyAddBtnValidationRepository>()),
    );

    Get.lazyPut<BagDoneSubmitDataSource>(
      () => BagDoneSubmitRemoteDataSourceImpl(Get.find<ApiClient>()),
    );
    Get.lazyPut<BagDoneSubmitRepository>(
      () => BagDoneSubmitRepositoryImpl(Get.find<BagDoneSubmitDataSource>()),
    );
    Get.lazyPut<SubmitBagDoneUseCase>(
      () => SubmitBagDoneUseCase(Get.find<BagDoneSubmitRepository>()),
    );

    Get.put(
      BagCompletionController(
        bag,
        Get.find<GetCurrentEmployeeUseCase>(),
        Get.find<GetBagCompletionMasterUseCase>(),
        Get.find<GetSubWorkTypesUseCase>(),
        Get.find<ValidateAddBtnUseCase>(),
        Get.find<SubmitBagDoneUseCase>(),
      ),
    );
  }
}
