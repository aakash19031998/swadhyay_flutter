import '../../../../core/config/app_config.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../models/bag_media_model.dart';
import 'bag_media_gallery_data_source.dart';

class BagMediaGalleryMockDataSourceImpl implements BagMediaGalleryDataSource {
  static const String _sampleVideoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  @override
  Future<List<BagMediaModel>> getMedia({required String empCd, required String styleCd}) async {
    await Future.delayed(AppConfig.mockLatency);

    return [
      for (int i = 0; i < 4; i++)
        BagMediaModel(url: 'https://picsum.photos/seed/$styleCd-$i/800/800', type: BagMediaType.image),
      const BagMediaModel(url: _sampleVideoUrl, type: BagMediaType.video),
    ];
  }
}
