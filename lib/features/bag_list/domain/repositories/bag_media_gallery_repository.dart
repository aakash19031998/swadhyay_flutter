import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_media_entity.dart';

abstract class BagMediaGalleryRepository {
  /// Every image/video that actually exists for [styleCd] — entries the
  /// backend lists but whose URL doesn't resolve are already filtered out
  /// by the data source, never reaching here.
  Future<Either<Failure, List<BagMediaEntity>>> getMedia({required String empCd, required String styleCd});
}
