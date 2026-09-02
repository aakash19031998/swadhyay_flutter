import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/sub_work_type_entity.dart';
import '../../domain/repositories/sub_work_type_repository.dart';
import '../datasources/sub_work_type_data_source.dart';

class SubWorkTypeRepositoryImpl implements SubWorkTypeRepository {
  SubWorkTypeRepositoryImpl(this._dataSource);

  final SubWorkTypeDataSource _dataSource;

  @override
  Future<Either<Failure, List<SubWorkTypeEntity>>> getSubWorkTypes({
    required String schr,
    required String workType,
    required String empCd,
  }) {
    return guard(() async {
      final options = await _dataSource.getSubWorkTypes(schr: schr, workType: workType, empCd: empCd);
      return options;
    });
  }
}
