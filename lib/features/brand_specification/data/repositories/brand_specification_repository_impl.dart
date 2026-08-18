import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../../domain/repositories/brand_specification_repository.dart';
import '../datasources/brand_specification_data_source.dart';

class BrandSpecificationRepositoryImpl implements BrandSpecificationRepository {
  BrandSpecificationRepositoryImpl(this._dataSource);

  final BrandSpecificationDataSource _dataSource;

  @override
  Future<Either<Failure, List<BrandEntity>>> getBrands() async {
    try {
      return Right(await _dataSource.getBrands());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<BrandSpecificationEntity>>> getSpecifications({required String brandId}) async {
    try {
      return Right(await _dataSource.getSpecifications(brandId: brandId));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
