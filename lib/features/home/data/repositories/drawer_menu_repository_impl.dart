import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/drawer_menu_item_entity.dart';
import '../../domain/repositories/drawer_menu_repository.dart';
import '../datasources/drawer_menu_data_source.dart';

class DrawerMenuRepositoryImpl implements DrawerMenuRepository {
  DrawerMenuRepositoryImpl(this._dataSource);

  final DrawerMenuDataSource _dataSource;

  @override
  Future<Either<Failure, List<DrawerMenuItemEntity>>> getMenu() async {
    try {
      final items = await _dataSource.getMenu();
      return Right(items);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
