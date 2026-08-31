import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/brand_entity.dart';
import '../entities/brand_specification_entity.dart';

abstract class BrandSpecificationRepository {
  Future<Either<Failure, List<BrandEntity>>> getBrands();

  Future<Either<Failure, List<BrandSpecificationEntity>>> getSpecifications({required String brandId});

  Future<Either<Failure, String>> getSpecificationPdfUrl({
    required String productId,
    required String styleNo,
    required String custShortCd,
  });
}
