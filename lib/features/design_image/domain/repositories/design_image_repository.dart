import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/design_image_entity.dart';

abstract class DesignImageRepository {
  Future<Either<Failure, List<DesignImageEntity>>> getImages({String query = ''});
}
