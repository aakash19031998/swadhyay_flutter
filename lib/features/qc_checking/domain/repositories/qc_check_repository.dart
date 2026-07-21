import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_check_entity.dart';

abstract class QcCheckRepository {
  Future<Either<Failure, List<QcCheckEntity>>> getChecks({String query = ''});
}
