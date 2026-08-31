import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../qc_pending_dashboard/domain/entities/qc_assigned_bag_entity.dart';

abstract class QcCheckerBagSearchRepository {
  Future<Either<Failure, List<QcAssignedBagEntity>>> searchBag({
    required String bagBarcode,
  });
}
