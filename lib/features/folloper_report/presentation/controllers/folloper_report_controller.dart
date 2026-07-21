import 'package:dartz/dartz.dart';

import '../../../../core/base/list_state_controller.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/folloper_report_entity.dart';
import '../../domain/usecases/get_folloper_report_usecase.dart';

class FolloperReportController extends ListStateController<FolloperReportEntity> {
  FolloperReportController(this._getFolloperReportUseCase);

  final GetFolloperReportUseCase _getFolloperReportUseCase;

  @override
  Future<Either<Failure, List<FolloperReportEntity>>> fetch(String searchQuery) {
    return _getFolloperReportUseCase(query: searchQuery);
  }
}
