import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../../domain/repositories/qc_checker_bag_search_repository.dart';
import '../datasources/qc_checker_bag_search_data_source.dart';

class QcCheckerBagSearchRepositoryImpl implements QcCheckerBagSearchRepository {
  QcCheckerBagSearchRepositoryImpl(this._dataSource);

  final QcCheckerBagSearchDataSource _dataSource;

  @override
  Future<Either<Failure, List<QcAssignedBagEntity>>> searchBag({
    required String bagBarcode,
  }) async {
    try {
      final List<QcAssignedBagEntity> bags = await _dataSource.searchBag(
        bagBarcode: bagBarcode,
      );
      return Right(bags);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
