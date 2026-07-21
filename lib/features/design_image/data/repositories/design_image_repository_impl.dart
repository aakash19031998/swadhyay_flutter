import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/design_image_entity.dart';
import '../../domain/repositories/design_image_repository.dart';
import '../datasources/design_image_data_source.dart';

class DesignImageRepositoryImpl implements DesignImageRepository {
  DesignImageRepositoryImpl(this._dataSource);

  final DesignImageDataSource _dataSource;

  @override
  Future<Either<Failure, List<DesignImageEntity>>> getImages({String query = ''}) async {
    try {
      final images = await _dataSource.getImages(query: query);
      return Right(images);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    }
  }
}
