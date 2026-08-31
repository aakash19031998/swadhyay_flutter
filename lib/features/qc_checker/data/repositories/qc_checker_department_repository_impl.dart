import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qc_checker_department_list_entity.dart';
import '../../domain/repositories/qc_checker_department_repository.dart';
import '../datasources/qc_checker_department_data_source.dart';

class QcCheckerDepartmentRepositoryImpl
    implements QcCheckerDepartmentRepository {
  QcCheckerDepartmentRepositoryImpl(this._dataSource);

  final QcCheckerDepartmentDataSource _dataSource;

  @override
  Future<Either<Failure, QcCheckerDepartmentListEntity>> getDepartments({
    required String empCd,
  }) async {
    try {
      final QcCheckerDepartmentListEntity result = await _dataSource
          .getDepartments(empCd: empCd);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
