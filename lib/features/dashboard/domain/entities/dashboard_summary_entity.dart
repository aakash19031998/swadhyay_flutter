import 'package:equatable/equatable.dart';

import 'dashboard_artisan_summary_entity.dart';
import 'dashboard_metal_loss_entity.dart';
import 'dashboard_production_entity.dart';
import 'dashboard_quality_inspection_entity.dart';
import 'dashboard_target_achievement_entity.dart';

/// Everything the Dashboard screen shows for one selected department: the
/// five overview cards — Active Artisans, Today's Production, Quality
/// Inspection, Target and Achievement, and Metal Loss.
class DashboardSummaryEntity extends Equatable {
  const DashboardSummaryEntity({
    required this.artisans,
    required this.production,
    required this.qualityInspection,
    required this.targetAchievement,
    required this.metalLoss,
  });

  final DashboardArtisanSummaryEntity artisans;
  final DashboardProductionEntity production;
  final DashboardQualityInspectionEntity qualityInspection;
  final DashboardTargetAchievementEntity targetAchievement;
  final DashboardMetalLossEntity metalLoss;

  @override
  List<Object?> get props => [
    artisans,
    production,
    qualityInspection,
    targetAchievement,
    metalLoss,
  ];
}
