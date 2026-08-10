import '../../../../core/config/app_config.dart';
import '../../../bag_list/data/models/bag_media_model.dart';
import '../../../bag_list/domain/entities/bag_media_entity.dart';
import '../models/design_bom_item_model.dart';
import '../models/design_lab_detail_model.dart';
import '../models/design_master_model.dart';
import 'design_master_data_source.dart';

class DesignMasterMockDataSourceImpl implements DesignMasterDataSource {
  static const String _sampleImageUrl =
      'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?auto=format&fit=crop&w=800&q=80';
  static const String _sampleVideoUrl = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

  /// Several angles of the same design plus a turntable video — the full
  /// gallery opened from the screen's image card, via the same
  /// `BagMediaViewerView` the Bag List screen already uses.
  static const List<BagMediaModel> _sampleMedia = [
    BagMediaModel(url: _sampleImageUrl, type: BagMediaType.image),
    BagMediaModel(
      url: 'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?auto=format&fit=crop&w=800&q=80',
      type: BagMediaType.image,
    ),
    BagMediaModel(
      url: 'https://images.unsplash.com/photo-1611652022419-a9419f74343d?auto=format&fit=crop&w=800&q=80',
      type: BagMediaType.image,
    ),
    BagMediaModel(
      url: 'https://images.unsplash.com/photo-1603561591411-07134e71a2a9?auto=format&fit=crop&w=800&q=80',
      type: BagMediaType.image,
    ),
    BagMediaModel(url: _sampleVideoUrl, type: BagMediaType.video),
  ];

  static final Map<String, DesignMasterModel> _records = {
    'nf05639': DesignMasterModel(
      designCode: 'nf05639',
      imageUrl: _sampleImageUrl,
      media: _sampleMedia,
      designCtg: 'NK',
      designSctg: 'NK-FS',
      parts: '3',
      emrStyle: 'S-NF05639',
      designDate: '11/02/2024',
      totalDiaWt: '0.0030',
      defRingSize: 'N/A',
      cadWt: '0',
      modelWt: '0.0000',
      cadVol: 'N/A',
      metalWt: '',
      bomItems: const [
        DesignBomItemModel(
          srNo: 1,
          rmType: 'CON',
          rmCode: 'CONRNDWHSAP-RG2',
          sizeName: '1.50-1.50 RNDC',
          pcs: '2',
          rmWeight: '0.0010',
          setCode: 'H-PRNG',
          stonePosition: 'Side Stone',
        ),
        DesignBomItemModel(
          srNo: 2,
          rmType: 'CON',
          rmCode: 'CONRNDWHSAP-RG2',
          sizeName: '1.75-1.75 RNDC',
          pcs: '2',
          rmWeight: '0.0010',
          setCode: 'H-PRNG',
          stonePosition: 'Side Stone',
        ),
        DesignBomItemModel(
          srNo: 3,
          rmType: 'CON',
          rmCode: 'CONRNDWHSAP-RG2',
          sizeName: '2.00-2.00 RNDC',
          pcs: '3',
          rmWeight: '0.0010',
          setCode: 'H-PRNG',
          stonePosition: 'Side Stone',
        ),
        DesignBomItemModel(
          srNo: 4,
          rmType: 'S',
          rmCode: 'S925W',
          sizeName: '—',
          pcs: '0',
          rmWeight: '0.5400',
          setCode: '—',
          stonePosition: 'None',
        ),
      ],
      labDetails: const [
        DesignLabDetailModel(labourCd: 'CAST', labourNm: 'Casting', pcs: '1'),
        DesignLabDetailModel(labourCd: 'FINS', labourNm: 'Finishing', pcs: '1'),
        DesignLabDetailModel(labourCd: 'RHDM', labourNm: 'Rhodium', pcs: '1'),
        DesignLabDetailModel(labourCd: 'STMP', labourNm: 'Stamping', pcs: '1'),
        DesignLabDetailModel(labourCd: 'PKNG', labourNm: 'Packing', pcs: '1'),
        DesignLabDetailModel(labourCd: 'SOLD', labourNm: 'Soldering', pcs: '3'),
      ],
      history: 'New Master created by Pradnyesh. Silver wt. updated by Ankush on 06.03.2024.(Old cad wt-0.100)',
    ),
  };

  @override
  Future<DesignMasterModel?> getDesignMaster({required String styleNo}) async {
    await Future.delayed(AppConfig.mockLatency);
    return _records[styleNo.trim().toLowerCase()];
  }
}
