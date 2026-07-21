import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/drawer_menu_item_entity.dart';
import '../repositories/drawer_menu_repository.dart';

class GetDrawerMenuUseCase {
  const GetDrawerMenuUseCase(this._repository);

  final DrawerMenuRepository _repository;

  Future<Either<Failure, List<DrawerMenuItemEntity>>> call() => _repository.getMenu();
}
