import 'package:equatable/equatable.dart';

/// One `repairList` entry sent to `BagFinalReceive` — a repair item the
/// user actually specified a quantity for (see [QcActionDialog]'s
/// qty-greater-than-zero filter).
class QcRepairQtyEntity extends Equatable {
  const QcRepairQtyEntity({required this.repairId, required this.qty});

  final int repairId;
  final int qty;

  @override
  List<Object?> get props => [repairId, qty];
}
