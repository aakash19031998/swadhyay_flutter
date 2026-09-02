import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/repository_guard.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../../domain/repositories/bag_media_gallery_repository.dart';
import '../datasources/bag_media_gallery_data_source.dart';

class BagMediaGalleryRepositoryImpl implements BagMediaGalleryRepository {
  BagMediaGalleryRepositoryImpl(this._dataSource);

  final BagMediaGalleryDataSource _dataSource;

  @override
  Future<Either<Failure, List<BagMediaEntity>>> getMedia({required String empCd, required String styleCd}) {
    return guard(() async {
      final media = await _dataSource.getMedia(empCd: empCd, styleCd: styleCd);
      return media;
    });
  }
}
