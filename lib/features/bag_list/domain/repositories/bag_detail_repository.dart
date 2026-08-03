import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_detail_entity.dart';

abstract class BagDetailRepository {
  Future<Either<Failure, BagDetailEntity>> getBagDetail({required String bagNo, required String empCd});
}
