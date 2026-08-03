import 'package:equatable/equatable.dart';

/// One row of the Bag Detail screen's "Diamond Details" tab.
class DiamondDetailEntity extends Equatable {
  const DiamondDetailEntity({
    required this.srNo,
    required this.itemCode,
    required this.size,
    required this.pcs,
    required this.weight,
    required this.setting,
  });

  final int srNo;
  final String itemCode;
  final double size;
  final int pcs;
  final double weight;
  final String setting;

  @override
  List<Object?> get props => [srNo, itemCode, size, pcs, weight, setting];
}
