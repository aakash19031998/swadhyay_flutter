import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../../domain/repositories/bag_media_gallery_repository.dart';
import '../datasources/bag_media_gallery_data_source.dart';

class BagMediaGalleryRepositoryImpl implements BagMediaGalleryRepository {
  BagMediaGalleryRepositoryImpl(this._dataSource);

  final BagMediaGalleryDataSource _dataSource;

  @override
  Future<Either<Failure, List<BagMediaEntity>>> getMedia({required String empCd, required String styleCd}) async {
    try {
      final media = await _dataSource.getMedia(empCd: empCd, styleCd: styleCd);
      return Right(media);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
