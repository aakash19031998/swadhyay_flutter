import '../../../../core/config/app_config.dart';
import '../models/brand_model.dart';
import '../models/brand_specification_model.dart';
import 'brand_specification_data_source.dart';

/// Mock-only for now — there is no `BrandMaster`/Brand Specification backend
/// endpoint yet. Wired in unconditionally (see `BrandSpecificationBinding`)
/// until the real endpoints exist; swap for a `*RemoteDataSourceImpl` then,
/// the same one-line change every other feature in this app made once its
/// own backend became available.
class BrandSpecificationMockDataSourceImpl implements BrandSpecificationDataSource {
  /// A real, stable, publicly-hosted PDF used purely so the download-and-
  /// open flow is testable before the backend has real per-row PDF links.
  static const String _samplePdfUrl = 'https://mozilla.github.io/pdf.js/web/compressed.tracemonkey-pldi-09.pdf';

  static const List<BrandModel> _brands = [
    BrandModel(id: 'brand_a', name: 'Brand A'),
    BrandModel(id: 'brand_b', name: 'Brand B'),
    BrandModel(id: 'brand_c', name: 'Brand C'),
  ];

  static const Map<String, List<BrandSpecificationModel>> _specifications = {
    'brand_a': [
      BrandSpecificationModel(
        productId: 'PID-1001',
        specHkStyle: 'HK-STY-101',
        custMaterial: '18KT-YG',
        specStyleKt: '18KT',
        specStyleCol: 'Yellow',
        specCustomer: 'Cust-A1',
        shortCode: 'SC-101',
        pdfUrl: _samplePdfUrl,
      ),
      BrandSpecificationModel(
        productId: 'PID-1002',
        specHkStyle: 'HK-STY-102',
        custMaterial: '14KT-WG',
        specStyleKt: '14KT',
        specStyleCol: 'White',
        specCustomer: 'Cust-A2',
        shortCode: 'SC-102',
        pdfUrl: _samplePdfUrl,
      ),
    ],
    'brand_b': [
      BrandSpecificationModel(
        productId: 'PID-2001',
        specHkStyle: 'HK-STY-201',
        custMaterial: '18KT-RG',
        specStyleKt: '18KT',
        specStyleCol: 'Rose',
        specCustomer: 'Cust-B1',
        shortCode: 'SC-201',
        pdfUrl: _samplePdfUrl,
      ),
    ],
    'brand_c': [],
  };

  @override
  Future<List<BrandModel>> getBrands() async {
    await Future.delayed(AppConfig.mockLatency);
    return _brands;
  }

  @override
  Future<List<BrandSpecificationModel>> getSpecifications({required String brandId}) async {
    await Future.delayed(AppConfig.mockLatency);
    return _specifications[brandId] ?? const [];
  }
}
