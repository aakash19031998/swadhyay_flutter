import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_detail_entity.dart';
import '../repositories/bag_detail_repository.dart';

class GetBagDetailUseCase {
  const GetBagDetailUseCase(this._repository);

  final BagDetailRepository _repository;

  Future<Either<Failure, BagDetailEntity>> call({required String bagNo, required String empCd}) {
    return _repository.getBagDetail(bagNo: bagNo, empCd: empCd);
  }
}
