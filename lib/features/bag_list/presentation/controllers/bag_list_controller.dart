import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/routes/app_routes.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/usecases/get_bags_usecase.dart';

class BagListController extends ListStateController<BagEntity> {
  BagListController(this._getBagsUseCase);

  final GetBagsUseCase _getBagsUseCase;

  @override
  Future<Either<Failure, List<BagEntity>>> fetch(String searchQuery) {
    return _getBagsUseCase(query: searchQuery);
  }

  void onBagDone(BagEntity bag) {
    Get.toNamed(AppRoutes.bagCompletion, arguments: bag);
  }
}
