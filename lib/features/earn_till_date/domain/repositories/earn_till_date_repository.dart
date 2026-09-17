import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/earn_till_date_entity.dart';

abstract class EarnTillDateRepository {
  Future<Either<Failure, EarnTillDateEntity>> getEarnTillDate({
    required String empCd,
    required String empName,
  });
}
