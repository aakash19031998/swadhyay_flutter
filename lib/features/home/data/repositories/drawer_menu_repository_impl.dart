import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../../domain/repositories/drawer_menu_repository.dart';
import '../datasources/drawer_menu_data_source.dart';

class DrawerMenuRepositoryImpl implements DrawerMenuRepository {
  DrawerMenuRepositoryImpl(this._dataSource);

  final DrawerMenuDataSource _dataSource;

  @override
  Future<Either<Failure, List<DrawerMenuItemEntity>>> getMenu(String empCd) {
    return guard(() async {
      final items = await _dataSource.getMenu(empCd);
      return items;
    });
  }
}
