import 'package:equatable/equatable.dart';

/// One row of the Design Master screen's "Lab Details" tab.
class DesignLabDetailEntity extends Equatable {
  const DesignLabDetailEntity({
    required this.labourCd,
    required this.labourNm,
    required this.pcs,
  });

  final String labourCd;
  final String labourNm;
  final String pcs;

  @override
  List<Object?> get props => [labourCd, labourNm, pcs];
}
