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
  Future<Either<Failure, List<BagEntity>>> getBags({String query = ''}) async {
    try {
      final bags = await _dataSource.getBags(query: query);
      return Right(bags);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
