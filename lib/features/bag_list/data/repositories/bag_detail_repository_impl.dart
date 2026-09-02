import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/bag_detail_entity.dart';
import '../../domain/repositories/bag_detail_repository.dart';
import '../datasources/bag_detail_data_source.dart';

class BagDetailRepositoryImpl implements BagDetailRepository {
  BagDetailRepositoryImpl(this._dataSource);

  final BagDetailDataSource _dataSource;

  @override
  Future<Either<Failure, BagDetailEntity>> getBagDetail({required String bagNo, required String empCd}) {
    return guard(() async {
      final detail = await _dataSource.getBagDetail(bagNo: bagNo, empCd: empCd);
      return detail;
    });
  }
}
