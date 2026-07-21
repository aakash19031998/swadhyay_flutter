import '../../../../core/config/app_config.dart';
import '../models/design_image_model.dart';
import 'design_image_data_source.dart';

class DesignImageMockDataSourceImpl implements DesignImageDataSource {
  static const List<String> _categories = ['Ring', 'Necklace', 'Bracelet', 'Earring'];

  static final List<DesignImageModel> _images = List.generate(20, (index) {
    return DesignImageModel(
      id: 'design_image_$index',
      designNo: 'DSN${(500 + index).toString()}',
      imageUrl: 'https://picsum.photos/seed/swadhyay-design-$index/400/400',
      category: _categories[index % _categories.length],
      uploadedAt: DateTime.now().subtract(Duration(days: index)),
    );
  });

  @override
  Future<List<DesignImageModel>> getImages({String query = ''}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (query.isEmpty) return _images;
    final String needle = query.toLowerCase();
    return _images
        .where((img) => img.designNo.toLowerCase().contains(needle) || img.category.toLowerCase().contains(needle))
        .toList();
  }
}
