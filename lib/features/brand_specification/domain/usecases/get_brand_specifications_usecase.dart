import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand_specification_entity.dart';
import '../repositories/brand_specification_repository.dart';

class GetBrandSpecificationsUseCase {
  const GetBrandSpecificationsUseCase(this._repository);

  final BrandSpecificationRepository _repository;

  Future<Either<Failure, List<BrandSpecificationEntity>>> call({required String brandId}) {
    return _repository.getSpecifications(brandId: brandId);
  }
}
