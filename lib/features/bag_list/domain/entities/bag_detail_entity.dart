import 'package:equatable/equatable.dart';

import 'bag_rm_summary_entity.dart';
import 'diamond_detail_entity.dart';

/// `BagDetailsNew`'s Bag Summary + Manufacturing Instructions data for one
/// bag — fetched once the Bag Detail screen opens and merged onto the
/// [BagEntity] the list screen already loaded (see
/// [BagEntity.copyWith]/`BagDetailController`), rather than living as its
/// own separate on-screen section. [diamondDetails]/[rmSummary] ride along
/// from the same response (`data.diamondDetails`/`data.rmSummary`, siblings
/// of `data.bag_Detail`).
class BagDetailEntity extends Equatable {
  const BagDetailEntity({
    this.delDate,
    this.bagQty,
    this.styleNo,
    this.orderNo,
    this.customer,
    this.part,
    this.size,
    this.designCategory,
    this.metal,
    this.designGrossWt,
    this.designNetWt,
    this.designInstr,
    this.custInstr,
    this.stampInstr,
    this.rhodInstr,
    this.diamInstr,
    this.sizeInstr,
    this.byy,
    this.bchr,
    this.bno,
    this.bagCmpCd,
    this.diamondDetails = const [],
    this.rmSummary = const [],
  });

  final DateTime? delDate;
  final int? bagQty;
  final String? styleNo;
  final String? orderNo;
  final String? customer;
  final String? part;
  final String? size;
  final String? designCategory;
  final String? metal;
  final double? designGrossWt;
  final double? designNetWt;
  final String? designInstr;
  final String? custInstr;
  final String? stampInstr;
  final String? rhodInstr;
  final String? diamInstr;
  final String? sizeInstr;

  // Raw bag-barcode components (e.g. "26/I1/55623" -> byy/bchr/bno) — see
  // BagEntity's matching fields.
  final String? byy;
  final String? bchr;
  final int? bno;
  final String? bagCmpCd;

  final List<DiamondDetailEntity> diamondDetails;
  final List<BagRmSummaryEntity> rmSummary;

  @override
  List<Object?> get props => [
        delDate,
        bagQty,
        styleNo,
        orderNo,
        customer,
        part,
        size,
        designCategory,
        metal,
        designGrossWt,
        designNetWt,
        designInstr,
        custInstr,
        stampInstr,
        rhodInstr,
        diamInstr,
        sizeInstr,
        byy,
        bchr,
        bno,
        bagCmpCd,
        diamondDetails,
        rmSummary,
      ];
}
