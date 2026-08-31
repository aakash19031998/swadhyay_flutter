import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_checker_department_list_entity.dart';

abstract class QcCheckerDepartmentRepository {
  Future<Either<Failure, QcCheckerDepartmentListEntity>> getDepartments({
    required String empCd,
  });
}
