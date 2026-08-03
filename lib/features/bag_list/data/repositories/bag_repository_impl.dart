import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bag_entity.dart';
import '../../domain/repositories/bag_repository.dart';
import '../datasources/bag_data_source.dart';

class BagRepositoryImpl implements BagRepository {
  BagRepositoryImpl(this._dataSource);

  final BagDataSource _dataSource;

  @override
  Future<Either<Failure, ({int bagCount, int pcsCount, List<BagEntity> bags})>> getBags({
    required String empCd,
  }) async {
    try {
      final result = await _dataSource.getBags(empCd: empCd);
      return Right((bagCount: result.bagCount, pcsCount: result.pcsCount, bags: result.bags.cast<BagEntity>()));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
