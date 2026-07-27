import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/drawer_menu_item_entity.dart';

abstract class DrawerMenuRepository {
  Future<Either<Failure, List<DrawerMenuItemEntity>>> getMenu(String empCd);
}
