import 'package:equatable/equatable.dart';

/// One row of the Bag Detail screen's "Diamond Details" tab.
class DiamondDetailEntity extends Equatable {
  const DiamondDetailEntity({
    required this.srNo,
    required this.shape,
    required this.sizeMm,
    required this.pcs,
    required this.weightCt,
    required this.color,
    required this.clarity,
    required this.setting,
  });

  final int srNo;
  final String shape;
  final double sizeMm;
  final int pcs;
  final double weightCt;
  final String color;
  final String clarity;
  final String setting;

  @override
  List<Object?> get props => [srNo, shape, sizeMm, pcs, weightCt, color, clarity, setting];
}
