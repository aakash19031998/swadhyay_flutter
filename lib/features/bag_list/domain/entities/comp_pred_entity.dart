import 'package:equatable/equatable.dart';

/// One row of `BagDoneDetail`'s `data.CompPred` array — a setting already
/// completed for this bag, shown in the Bag Completion screen's "Completed
/// Work" table.
class CompPredEntity extends Equatable {
  const CompPredEntity({required this.prediction, required this.stone});

  final String prediction;
  final double stone;

  @override
  List<Object?> get props => [prediction, stone];
}
