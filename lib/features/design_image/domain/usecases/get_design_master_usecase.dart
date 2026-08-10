import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/design_master_entity.dart';
import '../repositories/design_master_repository.dart';

class GetDesignMasterUseCase {
  const GetDesignMasterUseCase(this._repository);

  final DesignMasterRepository _repository;

  Future<Either<Failure, DesignMasterEntity?>> call({required String styleNo}) {
    return _repository.getDesignMaster(styleNo: styleNo);
  }
}
