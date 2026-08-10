import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/sub_work_type_entity.dart';

abstract class SubWorkTypeRepository {
  Future<Either<Failure, List<SubWorkTypeEntity>>> getSubWorkTypes({
    required String schr,
    required String workType,
    required String empCd,
  });
}
