import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/design_image_entity.dart';
import '../repositories/design_image_repository.dart';

class GetDesignImagesUseCase {
  const GetDesignImagesUseCase(this._repository);

  final DesignImageRepository _repository;

  Future<Either<Failure, List<DesignImageEntity>>> call({String query = ''}) {
    return _repository.getImages(query: query);
  }
}
