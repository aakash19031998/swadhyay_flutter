import 'package:get/get.dart';

import '../../../core/network/api_client.dart';
import '../data/datasources/bag_time_tracking_data_source.dart';
import '../data/datasources/bag_time_tracking_remote_data_source_impl.dart';
import '../data/repositories/bag_time_tracking_repository_impl.dart';
import '../domain/repositories/bag_time_tracking_repository.dart';
import '../domain/usecases/track_bag_time_usecase.dart';

/// Registers [TrackBagTimeUseCase] as an app-lifetime singleton.
///
/// `BagTimerController` calls this internally (not injected through a
/// constructor) since it's created via `BagTimerController.of(bagId)` —
/// a plain find-or-create lookup with no dependency-injection point of its
/// own. Whichever of the Bag List/Bag Detail bindings runs first performs
/// the registration; the other simply finds the existing instance. Same
/// idempotent pattern as `AuthDependencies`/`PauseReasonDependencies`. No
/// mock option — Start/Pause/Resume always call the live backend.
class BagTimeTrackingDependencies {
  const BagTimeTrackingDependencies._();

  static void ensureRegistered() {
    if (Get.isRegistered<BagTimeTrackingRepository>()) return;

    Get.put<BagTimeTrackingDataSource>(
      BagTimeTrackingRemoteDataSourceImpl(Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<BagTimeTrackingRepository>(
      BagTimeTrackingRepositoryImpl(Get.find<BagTimeTrackingDataSource>()),
      permanent: true,
    );

    Get.put<TrackBagTimeUseCase>(
      TrackBagTimeUseCase(Get.find<BagTimeTrackingRepository>()),
      permanent: true,
    );
  }
}
