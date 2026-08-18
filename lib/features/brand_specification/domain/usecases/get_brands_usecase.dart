import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';
import '../repositories/brand_specification_repository.dart';

class GetBrandsUseCase {
  const GetBrandsUseCase(this._repository);

  final BrandSpecificationRepository _repository;

  Future<Either<Failure, List<BrandEntity>>> call() => _repository.getBrands();
}
