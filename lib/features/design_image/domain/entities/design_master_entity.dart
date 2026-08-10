import 'package:equatable/equatable.dart';

import '../../../bag_list/domain/entities/bag_media_entity.dart';
import 'design_bom_item_entity.dart';
import 'design_lab_detail_entity.dart';

/// The single design record shown on the Design Master (Design Image)
/// screen once a style number has been searched. Every General-tab field is
/// a display-ready string, not a number — several legitimately hold non-
/// numeric placeholders (e.g. "N/A") straight from the source data.
///
/// [imageUrl] is just the static thumbnail shown on the screen itself;
/// [media] is the full image/video gallery opened from it — reusing
/// [BagMediaEntity] and the Bag List feature's own media viewer screen
/// rather than a second, near-identical one.
class DesignMasterEntity extends Equatable {
  const DesignMasterEntity({
    required this.designCode,
    required this.imageUrl,
    required this.designCtg,
    required this.designSctg,
    required this.parts,
    required this.emrStyle,
    required this.designDate,
    required this.totalDiaWt,
    required this.defRingSize,
    required this.cadWt,
    required this.modelWt,
    required this.cadVol,
    required this.metalWt,
    required this.bomItems,
    required this.labDetails,
    required this.history,
    this.media = const [],
  });

  final String designCode;
  final String imageUrl;
  final String designCtg;
  final String designSctg;
  final String parts;
  final String emrStyle;
  final String designDate;
  final String totalDiaWt;
  final String defRingSize;
  final String cadWt;
  final String modelWt;
  final String cadVol;
  final String metalWt;
  final List<DesignBomItemEntity> bomItems;
  final List<DesignLabDetailEntity> labDetails;
  final String history;
  final List<BagMediaEntity> media;

  @override
  List<Object?> get props => [
        designCode,
        imageUrl,
        designCtg,
        designSctg,
        parts,
        emrStyle,
        designDate,
        totalDiaWt,
        defRingSize,
        cadWt,
        modelWt,
        cadVol,
        metalWt,
        bomItems,
        labDetails,
        history,
        media,
      ];
}
