import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bag_media_entity.dart';
import '../repositories/bag_media_gallery_repository.dart';

class GetBagMediaUseCase {
  const GetBagMediaUseCase(this._repository);

  final BagMediaGalleryRepository _repository;

  Future<Either<Failure, List<BagMediaEntity>>> call({required String empCd, required String styleCd}) {
    return _repository.getMedia(empCd: empCd, styleCd: styleCd);
  }
}
