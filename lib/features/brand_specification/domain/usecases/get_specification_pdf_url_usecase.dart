import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/brand_specification_repository.dart';

class GetSpecificationPdfUrlUseCase {
  const GetSpecificationPdfUrlUseCase(this._repository);

  final BrandSpecificationRepository _repository;

  Future<Either<Failure, String>> call({
    required String productId,
    required String styleNo,
    required String custShortCd,
  }) {
    return _repository.getSpecificationPdfUrl(productId: productId, styleNo: styleNo, custShortCd: custShortCd);
  }
}
