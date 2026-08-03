import 'package:equatable/equatable.dart';

/// `BagDetailsNew`'s Bag Summary + Manufacturing Instructions data for one
/// bag — fetched once the Bag Detail screen opens and merged onto the
/// [BagEntity] the list screen already loaded (see
/// [BagEntity.copyWith]/`BagDetailController`), rather than living as its
/// own separate on-screen section.
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
      ];
}
