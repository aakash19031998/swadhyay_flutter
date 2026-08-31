import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_entity.dart';

abstract class BagRepository {
  Future<Either<Failure, ({int bagCount, int pcsCount, String noWorkStatus, String noWorkRunning, List<BagEntity> bags})>>
      getBags({required String empCd});
}
