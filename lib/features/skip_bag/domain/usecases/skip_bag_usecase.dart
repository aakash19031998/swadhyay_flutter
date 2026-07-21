import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/skipped_bag_entity.dart';
import '../repositories/skip_bag_repository.dart';

class SkipBagParams {
  const SkipBagParams({required this.bagNo, required this.reason});

  final String bagNo;
  final String reason;
}

class SkipBagUseCase {
  const SkipBagUseCase(this._repository);

  final SkipBagRepository _repository;

  Future<Either<Failure, SkippedBagEntity>> call(SkipBagParams params) {
    return _repository.skipBag(bagNo: params.bagNo, reason: params.reason);
  }
}
