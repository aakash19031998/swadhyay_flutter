import '../../../../core/config/app_config.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../models/bag_media_model.dart';
import '../models/bag_model.dart';
import 'bag_data_source.dart';

class BagMockDataSourceImpl implements BagDataSource {
  static const String _sampleVideoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  static List<BagMediaModel> _mediaFor(int index) {
    final int imageCount = 3 + (index % 3);
    final List<BagMediaModel> media = List.generate(
      imageCount,
      (i) => BagMediaModel(
        url: 'https://picsum.photos/seed/swadhyay-bag-$index-$i/800/800',
        type: BagMediaType.image,
      ),
    );
    if (index.isEven) {
      media.add(const BagMediaModel(url: _sampleVideoUrl, type: BagMediaType.video));
    }
    return media;
  }
  static const List<String> _designNos = [
    'PF24014-4YXXX-MUF0',
    'RE21064-4WLS2-KJL0',
    'RE21308-4YLS2-KJL0',
    'RE21050-4WLS2-KJF0',
    'PF23804-STXXX-MUF0',
  ];

  static const List<String> _locationCodes = [
    'ZAS1/1011371/540',
    'ZMAS/2100134/10',
    'ZMAS/2100133/10',
    'ZAFI/2501702/20',
    'ZAS1/1017444/380',
  ];

  static const List<String> _fillings = ['PREMIUM', 'Normal'];

  static const List<double> _designPoints = [8, 2, 2, 2.5, 2];

  static final List<BagModel> _bags = List.generate(18, (index) {
    final List<BagMediaModel> media = _mediaFor(index);
    return BagModel(
      id: 'bag_$index',
      bagNo: '${1200000000 + index * 5023}',
      designNo: _designNos[index % _designNos.length],
      imageUrl: media.first.url,
      locationCode: _locationCodes[index % _locationCodes.length],
      filling: _fillings[index % _fillings.length],
      bagQty: (index % 3) + 1,
      designPoints: _designPoints[index % _designPoints.length],
      assignedDate: DateTime.now().subtract(Duration(days: index)),
      media: media,
    );
  });

  @override
  Future<List<BagModel>> getBags({String query = ''}) async {
    await Future.delayed(AppConfig.mockLatency);

    if (query.isEmpty) return _bags;
    final String needle = query.toLowerCase();
    return _bags
        .where((bag) => bag.bagNo.toLowerCase().contains(needle) || bag.designNo.toLowerCase().contains(needle))
        .toList();
  }
}
