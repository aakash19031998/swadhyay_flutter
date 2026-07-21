import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_entity.dart';
import '../repositories/bag_repository.dart';

class GetBagsUseCase {
  const GetBagsUseCase(this._repository);

  final BagRepository _repository;

  Future<Either<Failure, List<BagEntity>>> call({String query = ''}) {
    return _repository.getBags(query: query);
  }
}
