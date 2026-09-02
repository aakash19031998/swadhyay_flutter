import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/pause_reason_entity.dart';
import '../../domain/repositories/pause_reason_repository.dart';
import '../datasources/pause_reason_data_source.dart';

class PauseReasonRepositoryImpl implements PauseReasonRepository {
  PauseReasonRepositoryImpl(this._dataSource);

  final PauseReasonDataSource _dataSource;

  @override
  Future<Either<Failure, List<PauseReasonEntity>>> getReasons() {
    return guard(() async {
      final reasons = await _dataSource.getReasons();
      return reasons;
    });
  }
}
