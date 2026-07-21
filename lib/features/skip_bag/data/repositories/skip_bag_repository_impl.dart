import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/skipped_bag_entity.dart';
import '../../domain/repositories/skip_bag_repository.dart';
import '../datasources/skip_bag_data_source.dart';

class SkipBagRepositoryImpl implements SkipBagRepository {
  SkipBagRepositoryImpl(this._dataSource);

  final SkipBagDataSource _dataSource;

  @override
  Future<Either<Failure, List<SkippedBagEntity>>> getSkippedBags({String query = ''}) async {
    try {
      final bags = await _dataSource.getSkippedBags(query: query);
      return Right(bags);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, SkippedBagEntity>> skipBag({required String bagNo, required String reason}) async {
    try {
      final entry = await _dataSource.skipBag(bagNo: bagNo, reason: reason);
      return Right(entry);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
