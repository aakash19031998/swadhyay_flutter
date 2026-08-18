import '../../domain/entities/brand_specification_entity.dart';

class BrandSpecificationModel extends BrandSpecificationEntity {
  const BrandSpecificationModel({
    required super.productId,
    required super.specHkStyle,
    required super.custMaterial,
    required super.specStyleKt,
    required super.specStyleCol,
    required super.specCustomer,
    required super.shortCode,
    required super.pdfUrl,
  });
}
