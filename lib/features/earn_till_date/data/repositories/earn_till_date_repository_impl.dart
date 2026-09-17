import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/earn_till_date_entity.dart';
import '../../domain/repositories/earn_till_date_repository.dart';
import '../datasources/earn_till_date_data_source.dart';

class EarnTillDateRepositoryImpl implements EarnTillDateRepository {
  EarnTillDateRepositoryImpl(this._dataSource);

  final EarnTillDateDataSource _dataSource;

  @override
  Future<Either<Failure, EarnTillDateEntity>> getEarnTillDate({
    required String empCd,
    required String empName,
  }) {
    return guard(
      () => _dataSource.getEarnTillDate(empCd: empCd, empName: empName),
    );
  }
}
