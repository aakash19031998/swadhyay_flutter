import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/design_master_entity.dart';
import '../../domain/repositories/design_master_repository.dart';
import '../datasources/design_master_data_source.dart';

class DesignMasterRepositoryImpl implements DesignMasterRepository {
  DesignMasterRepositoryImpl(this._dataSource);

  final DesignMasterDataSource _dataSource;

  @override
  Future<Either<Failure, DesignMasterEntity?>> getDesignMaster({required String styleNo}) {
    return guard(() async {
      final design = await _dataSource.getDesignMaster(styleNo: styleNo);
      return design;
    });
  }
}
