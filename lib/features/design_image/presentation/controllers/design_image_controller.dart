import 'package:dartz/dartz.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/design_image_entity.dart';
import '../../domain/usecases/get_design_images_usecase.dart';

class DesignImageController extends ListStateController<DesignImageEntity> {
  DesignImageController(this._getDesignImagesUseCase);

  final GetDesignImagesUseCase _getDesignImagesUseCase;

  @override
  Future<Either<Failure, List<DesignImageEntity>>> fetch(String searchQuery) {
    return _getDesignImagesUseCase(query: searchQuery);
  }
}
