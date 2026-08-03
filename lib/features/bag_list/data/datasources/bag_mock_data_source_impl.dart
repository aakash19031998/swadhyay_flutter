import '../../../../core/config/app_config.dart';
import '../../domain/entities/bag_media_entity.dart';
import '../models/bag_media_model.dart';
import '../models/bag_model.dart';
import '../models/bag_rm_summary_model.dart';
import '../models/diamond_detail_model.dart';
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

  static const List<String> _designCategories = ['Necklace', 'Ring', 'Earring', 'Bracelet', 'Pendant'];

  // The department a bag is currently sitting in — changes as it moves
  // through the process, so it's driven by data, never a fixed label.
  static const List<String> _departments = ['Filling', 'Setting', 'Polishing', 'Casting', 'Quality Check'];

  static const List<double> _designPoints = [8, 2, 2, 2.5, 2];

  // Manufacturing instructions (Bag Detail screen) — rotates across two
  // sample specs so every bag isn't identical.
  static const List<String> _metals = ['18K Yellow Gold', '14K White Gold'];
  static const List<double> _grossWeights = [8.50, 6.25];
  static const List<double> _netWeights = [7.20, 5.10];
  static const List<String> _customers = ['HK Design', 'Aurelia Jewels'];

  static List<DiamondDetailModel> _diamondDetailsFor(int index) {
    return [
      DiamondDetailModel(
        srNo: 1,
        itemCode: 'DIA-${1200 + index}',
        size: 1.50,
        pcs: 12,
        weight: 0.18,
        setting: 'Prong',
      ),
      DiamondDetailModel(
        srNo: 2,
        itemCode: 'DIA-${1300 + index}',
        size: 2.00,
        pcs: 6,
        weight: 0.24,
        setting: 'Pave',
      ),
    ];
  }

  static List<BagRmSummaryModel> _rmSummaryFor(int index) {
    return [
      BagRmSummaryModel(
        materialType: _metals[index % _metals.length],
        itemCode: 'RM-${10023 + index}',
        size: '7.0 US',
        issuedQty: '9.00 grm',
      ),
    ];
  }

  static final List<BagModel> _bags = List.generate(18, (index) {
    final List<BagMediaModel> media = _mediaFor(index);
    return BagModel(
      id: 'bag_$index',
      bagNo: '${1200000000 + index * 5023}',
      designNo: _designNos[index % _designNos.length],
      imageUrl: media.first.url,
      locationCode: _locationCodes[index % _locationCodes.length],
      designCategory: _designCategories[index % _designCategories.length],
      department: _departments[index % _departments.length],
      filling: _fillings[index % _fillings.length],
      bagQty: (index % 3) + 1,
      designPoints: _designPoints[index % _designPoints.length],
      assignedDate: DateTime.now().subtract(Duration(days: index)),
      media: media,
      metal: _metals[index % _metals.length],
      designGrossWt: _grossWeights[index % _grossWeights.length],
      designNetWt: _netWeights[index % _netWeights.length],
      designInstr: 'High polish finish required.',
      custInstr: 'Laser engrave logo on shank.',
      stampInstr: '18K Hallmark Stamp',
      rhodInstr: 'Rhodium dip on prongs',
      diamInstr: 'Use VS clarity diamonds only',
      sizeInstr: 'Standard 7.0 US Ring Size',
      delDate: DateTime.now().add(Duration(days: 5 + index)),
      size: '7.0 US',
      customer: _customers[index % _customers.length],
      poNo: 'PO-${99238 + index}',
      part: 'Main Body',
      pieceQty: 1,
      styleNo: 'ST-${4400 + index}',
      diamondDetails: _diamondDetailsFor(index),
      rmSummary: _rmSummaryFor(index),
    );
  });

  @override
  Future<({int bagCount, int pcsCount, List<BagModel> bags})> getBags({required String empCd}) async {
    await Future.delayed(AppConfig.mockLatency);

    return (
      bagCount: _bags.length,
      pcsCount: _bags.fold(0, (sum, bag) => sum + bag.bagQty),
      bags: _bags,
    );
  }
}
