import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../../domain/repositories/brand_specification_repository.dart';
import '../datasources/brand_specification_data_source.dart';

class BrandSpecificationRepositoryImpl implements BrandSpecificationRepository {
  BrandSpecificationRepositoryImpl(this._dataSource);

  final BrandSpecificationDataSource _dataSource;

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands() {
    return guard(() async {
      return await _dataSource.getBrands();
    });
  }

  @override
  Future<Either<Failure, List<BrandSpecificationEntity>>> getSpecifications({required String brandId}) {
    return guard(() async {
      return await _dataSource.getSpecifications(brandId: brandId);
    });
  }

  @override
  Future<Either<Failure, String>> getSpecificationPdfUrl({
    required String productId,
    required String styleNo,
    required String custShortCd,
  }) {
    return guard(() async {
      return await _dataSource.getSpecificationPdfUrl(productId: productId, styleNo: styleNo, custShortCd: custShortCd);
    });
  }
}
