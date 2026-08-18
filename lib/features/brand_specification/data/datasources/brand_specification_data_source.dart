import '../models/brand_model.dart';
import '../models/brand_specification_model.dart';

abstract class BrandSpecificationDataSource {
  Future<List<BrandModel>> getBrands();

  Future<List<BrandSpecificationModel>> getSpecifications({required String brandId});
}
