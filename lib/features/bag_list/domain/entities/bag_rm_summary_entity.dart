import 'package:equatable/equatable.dart';

/// One row of the Bag Detail screen's "Bag RM Summary" tab. Quantities are
/// kept as display-ready strings (e.g. "9.00 grm") since the unit varies by
/// material and formatting it belongs to whatever produces the data, not
/// this entity.
class BagRmSummaryEntity extends Equatable {
  const BagRmSummaryEntity({
    required this.materialCode,
    required this.description,
    required this.allocatedQty,
    required this.issuedQty,
    required this.status,
  });

  final String materialCode;
  final String description;
  final String allocatedQty;
  final String issuedQty;
  final String status;

  @override
  List<Object?> get props => [materialCode, description, allocatedQty, issuedQty, status];
}
