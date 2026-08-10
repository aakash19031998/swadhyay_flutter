import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/pause_reason_data_source.dart';
import '../data/datasources/pause_reason_remote_data_source_impl.dart';
import '../data/repositories/pause_reason_repository_impl.dart';
import '../domain/repositories/pause_reason_repository.dart';
import '../domain/usecases/get_pause_reasons_usecase.dart';

/// Registers [GetPauseReasonsUseCase] as an app-lifetime singleton.
///
/// `PauseReasonDialog` is opened from both the Bag List screen (grid card's
/// Pause button) and the Bag Detail screen's own Pause action — whichever
/// of the two screens is entered first performs the registration, the
/// other simply finds the existing instance. Same idempotent pattern as
/// `AuthDependencies`. No mock option — the reason dropdown always comes
/// from the live `PauseReasonMaster` backend.
class PauseReasonDependencies {
  const PauseReasonDependencies._();

  static void ensureRegistered() {
    if (Get.isRegistered<PauseReasonRepository>()) return;

    Get.put<PauseReasonDataSource>(
      PauseReasonRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<PauseReasonRepository>(
      PauseReasonRepositoryImpl(Get.find<PauseReasonDataSource>()),
      permanent: true,
    );

    Get.put<GetPauseReasonsUseCase>(
      GetPauseReasonsUseCase(Get.find<PauseReasonRepository>()),
      permanent: true,
    );
  }
}
