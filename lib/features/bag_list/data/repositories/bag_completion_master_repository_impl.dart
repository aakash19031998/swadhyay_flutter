import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/bag_completion_master_entity.dart';
import '../../domain/repositories/bag_completion_master_repository.dart';
import '../datasources/bag_completion_master_data_source.dart';

class BagCompletionMasterRepositoryImpl implements BagCompletionMasterRepository {
  BagCompletionMasterRepositoryImpl(this._dataSource);

  final BagCompletionMasterDataSource _dataSource;

  @override
  Future<Either<Failure, BagCompletionMasterEntity>> getBagCompletionMaster({
    required String trnId,
    required String empCd,
  }) {
    return guard(() async {
      final master = await _dataSource.getBagCompletionMaster(trnId: trnId, empCd: empCd);
      return master;
    });
  }
}
