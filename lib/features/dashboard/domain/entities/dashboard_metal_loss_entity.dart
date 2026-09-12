import 'package:equatable/equatable.dart';

class DashboardMetalLossEntity extends Equatable {
  const DashboardMetalLossEntity({
    required this.lossRatePercent,
    required this.normThreshold,
    required this.todayGrossLoss,
    required this.mtdLoss,
  });

  final double lossRatePercent;
  final double normThreshold;
  final double todayGrossLoss;
  final double mtdLoss;

  @override
  List<Object?> get props => [
    lossRatePercent,
    normThreshold,
    todayGrossLoss,
    mtdLoss,
  ];
}
