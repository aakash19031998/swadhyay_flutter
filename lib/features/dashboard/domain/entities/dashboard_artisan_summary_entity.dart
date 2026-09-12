import 'package:equatable/equatable.dart';

/// One skill-category tile on the "Active Artisans" card (e.g. "CAT A — 18
/// — Master / Halo").
class DashboardArtisanCategoryEntity extends Equatable {
  const DashboardArtisanCategoryEntity({
    required this.label,
    required this.count,
    required this.subtitle,
  });

  final String label;
  final int count;
  final String subtitle;

  @override
  List<Object?> get props => [label, count, subtitle];
}

class DashboardArtisanSummaryEntity extends Equatable {
  const DashboardArtisanSummaryEntity({
    required this.activeCount,
    required this.totalRoster,
    required this.onFloorPercent,
    required this.categories,
  });

  final int activeCount;
  final int totalRoster;
  final int onFloorPercent;
  final List<DashboardArtisanCategoryEntity> categories;

  @override
  List<Object?> get props => [
    activeCount,
    totalRoster,
    onFloorPercent,
    categories,
  ];
}
