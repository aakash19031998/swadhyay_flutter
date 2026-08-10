import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/design_master_entity.dart';

abstract class DesignMasterRepository {
  /// Returns `null` on the right side when no design matches [styleNo] —
  /// distinct from a [Failure], which means the fetch itself broke.
  Future<Either<Failure, DesignMasterEntity?>> getDesignMaster({required String styleNo});
}
