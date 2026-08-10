import 'package:equatable/equatable.dart';

/// One row of the Bag Detail screen's "Bag RM Summary" tab. [issuedQty] and
/// [wt] are kept as display-ready strings (e.g. "9.00 grm") since the unit
/// varies by material and formatting it belongs to whatever produces the
/// data, not this entity.
class BagRmSummaryEntity extends Equatable {
  const BagRmSummaryEntity({
    required this.materialType,
    required this.itemCode,
    required this.size,
    required this.issuedQty,
    required this.wt,
  });

  final String materialType;
  final String itemCode;
  final String size;
  final String issuedQty;
  final String wt;

  @override
  List<Object?> get props => [materialType, itemCode, size, issuedQty, wt];
}
