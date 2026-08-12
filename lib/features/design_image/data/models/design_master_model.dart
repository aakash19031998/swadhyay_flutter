import '../../../bag_list/data/models/bag_media_model.dart';
import '../../../bag_list/domain/entities/bag_media_entity.dart';
import '../../domain/entities/design_bom_item_entity.dart';
import '../../domain/entities/design_lab_detail_entity.dart';
import '../../domain/entities/design_master_entity.dart';
import 'design_bom_item_model.dart';
import 'design_lab_detail_model.dart';

class DesignMasterModel extends DesignMasterEntity {
  const DesignMasterModel({
    required super.designCode,
    required super.imageUrl,
    required super.designCtg,
    required super.designSctg,
    required super.parts,
    required super.emrStyle,
    required super.designDate,
    required super.totalDiaWt,
    required super.defRingSize,
    required super.cadWt,
    required super.modelWt,
    required super.cadVol,
    required super.metalWt,
    required super.grossWt,
    required super.bomItems,
    required super.labDetails,
    required super.history,
    super.media,
  });

  factory DesignMasterModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> bomJson = json['bomItems'] as List<dynamic>? ?? const [];
    final List<dynamic> labJson = json['labDetails'] as List<dynamic>? ?? const [];
    final List<dynamic> mediaJson = json['media'] as List<dynamic>? ?? const [];
    final List<DesignBomItemEntity> bomItems = [
      for (final entry in bomJson) DesignBomItemModel.fromJson(entry as Map<String, dynamic>),
    ];
    final List<DesignLabDetailEntity> labDetails = [
      for (final entry in labJson) DesignLabDetailModel.fromJson(entry as Map<String, dynamic>),
    ];
    final List<BagMediaEntity> media = [
      for (final entry in mediaJson) BagMediaModel.fromJson(entry as Map<String, dynamic>),
    ];

    return DesignMasterModel(
      designCode: json['designCode'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      designCtg: json['designCtg'] as String? ?? '',
      designSctg: json['designSctg'] as String? ?? '',
      parts: '${json['parts'] ?? ''}',
      emrStyle: json['emrStyle'] as String? ?? '',
      designDate: json['designDate'] as String? ?? '',
      totalDiaWt: '${json['totalDiaWt'] ?? ''}',
      defRingSize: '${json['defRingSize'] ?? ''}',
      cadWt: '${json['cadWt'] ?? ''}',
      modelWt: '${json['modelWt'] ?? ''}',
      cadVol: '${json['cadVol'] ?? ''}',
      metalWt: '${json['MetalWt'] ?? ''}',
      grossWt: '${json['GrossWt'] ?? ''}',
      bomItems: bomItems,
      labDetails: labDetails,
      history: json['history'] as String? ?? '',
      media: media,
    );
  }
}
