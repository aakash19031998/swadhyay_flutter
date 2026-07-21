import 'package:dartz/dartz.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qc_check_entity.dart';
import '../../domain/usecases/get_qc_checks_usecase.dart';

class QcCheckingController extends ListStateController<QcCheckEntity> {
  QcCheckingController(this._getQcChecksUseCase);

  final GetQcChecksUseCase _getQcChecksUseCase;

  @override
  Future<Either<Failure, List<QcCheckEntity>>> fetch(String searchQuery) {
    return _getQcChecksUseCase(query: searchQuery);
  }
}
