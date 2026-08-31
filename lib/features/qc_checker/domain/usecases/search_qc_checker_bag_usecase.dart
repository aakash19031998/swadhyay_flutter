import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';
import '../repositories/qc_checker_bag_search_repository.dart';

class SearchQcCheckerBagUseCase {
  const SearchQcCheckerBagUseCase(this._repository);

  final QcCheckerBagSearchRepository _repository;

  Future<Either<Failure, List<QcAssignedBagEntity>>> call({
    required String bagBarcode,
  }) {
    return _repository.searchBag(bagBarcode: bagBarcode);
  }
}
