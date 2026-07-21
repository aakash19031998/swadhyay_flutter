import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/skipped_bag_entity.dart';

abstract class SkipBagRepository {
  Future<Either<Failure, List<SkippedBagEntity>>> getSkippedBags({String query = ''});

  Future<Either<Failure, SkippedBagEntity>> skipBag({required String bagNo, required String reason});
}
