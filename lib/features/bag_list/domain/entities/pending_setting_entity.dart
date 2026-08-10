import 'package:equatable/equatable.dart';

/// One row of `BagDoneDetail`'s `data.PndPred` array — a setting already
/// known/expected for this bag, shown (after the Bag Completion screen's
/// table-name swap) in the table now titled "Pending Setting".
class PendingSettingEntity extends Equatable {
  const PendingSettingEntity({
    required this.trnId,
    required this.setId,
    required this.pred,
    required this.pcs,
  });

  final String trnId;
  final int setId;
  final String pred;
  final int pcs;

  @override
  List<Object?> get props => [trnId, setId, pred, pcs];
}
