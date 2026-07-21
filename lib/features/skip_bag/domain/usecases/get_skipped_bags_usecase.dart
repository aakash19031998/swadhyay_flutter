import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/skipped_bag_entity.dart';
import '../repositories/skip_bag_repository.dart';

class GetSkippedBagsUseCase {
  const GetSkippedBagsUseCase(this._repository);

  final SkipBagRepository _repository;

  Future<Either<Failure, List<SkippedBagEntity>>> call({String query = ''}) {
    return _repository.getSkippedBags(query: query);
  }
}
