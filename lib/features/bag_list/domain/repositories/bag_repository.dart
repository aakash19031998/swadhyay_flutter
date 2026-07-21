import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_entity.dart';

abstract class BagRepository {
  Future<Either<Failure, List<BagEntity>>> getBags({String query = ''});
}
