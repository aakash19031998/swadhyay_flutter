import 'package:equatable/equatable.dart';

/// One row of the Design Master screen's "Bill Of Material" tab.
class DesignBomItemEntity extends Equatable {
  const DesignBomItemEntity({
    required this.srNo,
    required this.rmType,
    required this.rmCode,
    required this.sizeName,
    required this.pcs,
    required this.rmWeight,
    required this.setCode,
    required this.stonePosition,
  });

  final int srNo;
  final String rmType;
  final String rmCode;
  final String sizeName;
  final String pcs;
  final String rmWeight;
  final String setCode;
  final String stonePosition;

  @override
  List<Object?> get props => [srNo, rmType, rmCode, sizeName, pcs, rmWeight, setCode, stonePosition];
}
