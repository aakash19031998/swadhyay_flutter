import '../../../../core/config/app_config.dart';
import '../../domain/entities/dashboard_artisan_summary_entity.dart';
import '../../domain/entities/dashboard_department_entity.dart';
import '../../domain/entities/dashboard_kpi_detail_entity.dart';
import '../../domain/entities/dashboard_kpi_entity.dart';
import '../../domain/entities/dashboard_metal_loss_entity.dart';
import '../../domain/entities/dashboard_production_entity.dart';
import '../../domain/entities/dashboard_quality_inspection_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/entities/dashboard_target_achievement_entity.dart';
import 'dashboard_data_source.dart';

/// Placeholder data only — no backend endpoint exists for this screen yet.
/// Every department returns the same shape of summary, scaled by its
/// position in [_departments] so switching departments visibly changes the
/// numbers instead of looking frozen.
class DashboardMockDataSourceImpl implements DashboardDataSource {
  static const List<DashboardDepartmentEntity> _departments = [
    DashboardDepartmentEntity(
      id: 'cutting',
      name: 'Cutting',
      floorLabel: 'Floor #3',
    ),
    DashboardDepartmentEntity(
      id: 'polishing',
      name: 'Polishing',
      floorLabel: 'Floor #1',
    ),
    DashboardDepartmentEntity(
      id: 'setting',
      name: 'Setting',
      floorLabel: 'Floor #4',
    ),
    DashboardDepartmentEntity(id: 'qc', name: 'QC', floorLabel: 'Floor #2'),
  ];

  @override
  Future<List<DashboardDepartmentEntity>> getDepartments() async {
    await Future.delayed(AppConfig.mockLatency);
    return _departments;
  }

  @override
  Future<DashboardSummaryEntity> getSummary({
    required String departmentId,
  }) async {
    await Future.delayed(AppConfig.mockLatency);

    final int index = _departments.indexWhere(
      (department) => department.id == departmentId,
    );
    final double scale = 1 - (index.clamp(0, _departments.length - 1) * 0.18);

    int scaled(int base) => (base * scale).round();
    double scaledD(double base) => base * scale;

    return DashboardSummaryEntity(
      artisans: DashboardArtisanSummaryEntity(
        activeCount: scaled(64),
        totalRoster: 70,
        onFloorPercent: scaled(92),
        categories: [
          DashboardArtisanCategoryEntity(
            label: 'CAT A',
            count: scaled(18),
            subtitle: 'Master Setting',
          ),
          DashboardArtisanCategoryEntity(
            label: 'CAT B',
            count: scaled(32),
            subtitle: 'Prong / Pave',
          ),
          DashboardArtisanCategoryEntity(
            label: 'CAT C',
            count: scaled(14),
            subtitle: 'Filing / Polish',
          ),
        ],
      ),
      production: DashboardProductionEntity(
        shiftTarget: scaled(120),
        totalBacklog: scaled(18),
        completed: scaled(74),
        paceVsStandard: -scaled(6),
      ),
      qualityInspection: DashboardQualityInspectionEntity(
        piecesWaiting: scaled(42),
        urgentCount: scaled(6),
        queue: [
          DashboardQcQueueItemEntity(
            label: 'Stone Setting QC',
            pieces: scaled(24),
          ),
          DashboardQcQueueItemEntity(
            label: 'Final Buffing & Micron QC',
            pieces: scaled(18),
          ),
        ],
      ),
      targetAchievement: DashboardTargetAchievementEntity(
        weeklyTarget: scaled(850),
        outputToDate: scaled(610),
        days: [
          DashboardDayEntity(
            label: 'Mon',
            status: DashboardDayStatus.completed,
            percent: scaled(95),
          ),
          DashboardDayEntity(
            label: 'Tue',
            status: DashboardDayStatus.completed,
            percent: scaled(100),
          ),
          DashboardDayEntity(
            label: 'Wed',
            status: DashboardDayStatus.completed,
            percent: scaled(85),
          ),
          DashboardDayEntity(
            label: 'Thu',
            status: DashboardDayStatus.completed,
            percent: scaled(90),
          ),
          DashboardDayEntity(
            label: 'Today',
            status: DashboardDayStatus.current,
            percent: scaled(60),
          ),
          const DashboardDayEntity(
            label: 'Sat',
            status: DashboardDayStatus.upcoming,
            percent: 0,
          ),
        ],
      ),
      metalLoss: DashboardMetalLossEntity(
        lossRatePercent: scaledD(1.62),
        normThreshold: 1.80,
        todayGrossLoss: scaledD(2.415),
        mtdLoss: scaledD(48.250),
      ),
    );
  }

  static const List<DashboardKpiDetailColumn> _firstReceiveColumns = [
    DashboardKpiDetailColumn(label: 'LOT #', flex: 2),
    DashboardKpiDetailColumn(label: 'SOURCE / CONSIGNOR', flex: 3),
    DashboardKpiDetailColumn(label: 'TOTAL BAGS', flex: 2),
    DashboardKpiDetailColumn(label: 'GROSS WEIGHT', flex: 2),
    DashboardKpiDetailColumn(label: 'INTAKE TIME', flex: 2),
    DashboardKpiDetailColumn(label: 'PIPELINE STATUS', flex: 2),
  ];

  static const List<List<String>> _firstReceiveRows = [
    [
      '#LOT-1049',
      'Surat Cutting Plant Alpha',
      '34 Bags',
      '148.20 ct',
      '09:30 AM',
      'Pending Scan',
    ],
    [
      '#LOT-1052',
      'Navsari Parcel Inward',
      '52 Bags',
      '210.50 ct',
      '10:15 AM',
      'Pending Scan',
    ],
    [
      '#LOT-1055',
      'Intake Vault Locker 2',
      '40 Bags',
      '180.10 ct',
      '11:20 AM',
      'Logged',
    ],
    [
      '#LOT-1059',
      'Internal Transfer Line',
      '22 Bags',
      '94.80 ct',
      '12:05 PM',
      'Pending Scan',
    ],
  ];

  static const List<DashboardKpiDetailColumn> _qcPendingColumns = [
    DashboardKpiDetailColumn(label: 'TABLE #', flex: 2),
    DashboardKpiDetailColumn(label: 'ASSIGNED CHECKER', flex: 3),
    DashboardKpiDetailColumn(label: 'PROCESS', flex: 2),
    DashboardKpiDetailColumn(label: 'BAGS QUEUED', flex: 2),
    DashboardKpiDetailColumn(label: 'WAIT TIME', flex: 2),
    DashboardKpiDetailColumn(label: 'PRIORITY', flex: 2),
  ];

  static const List<List<String>> _qcPendingRows = [
    ['QT-201', 'Alok Sardar', '1st Receive', '8 Bags', '12 mins', 'High'],
    ['QT-204', 'Dipesh Mohit', 'QC Check', '5 Bags', '25 mins', 'Normal'],
    ['QT-207', 'Sayaji Dharne', '1st Receive', '3 Bags', '40 mins', 'High'],
    ['QT-210', 'Arunesh Giri', 'QC Check', '6 Bags', '18 mins', 'Normal'],
  ];

  static const List<DashboardKpiDetailColumn> _articleCountColumns = [
    DashboardKpiDetailColumn(label: 'ARTICLE ID', flex: 2),
    DashboardKpiDetailColumn(label: 'CATEGORY', flex: 2),
    DashboardKpiDetailColumn(label: 'CARAT WEIGHT', flex: 2),
    DashboardKpiDetailColumn(label: 'QUANTITY', flex: 2),
    DashboardKpiDetailColumn(label: 'LOCATION', flex: 2),
    DashboardKpiDetailColumn(label: 'STATUS', flex: 2),
  ];

  static const List<List<String>> _articleCountRows = [
    [
      'ART-3301',
      'Solitaire Ring',
      '1.20 ct',
      '45 pcs',
      'Vault A-2',
      'In Stock',
    ],
    [
      'ART-3348',
      'Diamond Necklace',
      '3.50 ct',
      '12 pcs',
      'Vault B-1',
      'Reserved',
    ],
    ['ART-3390', 'Stud Earrings', '0.80 ct', '60 pcs', 'Vault A-4', 'In Stock'],
    [
      'ART-3422',
      'Tennis Bracelet',
      '5.10 ct',
      '8 pcs',
      'Vault C-1',
      'In Stock',
    ],
  ];

  static const List<DashboardKpiDetailColumn> _empCountColumns = [
    DashboardKpiDetailColumn(label: 'EMP CODE', flex: 2),
    DashboardKpiDetailColumn(label: 'NAME', flex: 3),
    DashboardKpiDetailColumn(label: 'DEPARTMENT', flex: 2),
    DashboardKpiDetailColumn(label: 'SHIFT', flex: 2),
    DashboardKpiDetailColumn(label: 'STATUS', flex: 2),
  ];

  static const List<List<String>> _empCountRows = [
    ['10228', 'Alok Sardar', '1st Receive', 'Day', 'Active'],
    ['10230', 'Dipesh Mohit', 'QC Check', 'Day', 'Active'],
    ['10247', 'Sayaji Dharne', '1st Receive', 'Evening', 'On Leave'],
    ['12385', 'Arunesh Giri', 'QC Check', 'Day', 'Active'],
  ];

  @override
  Future<DashboardKpiDetailEntity> getKpiDetail({
    required String departmentId,
    required DashboardKpiKind kind,
  }) async {
    await Future.delayed(AppConfig.mockLatency);
    return switch (kind) {
      DashboardKpiKind.firstReceive => const DashboardKpiDetailEntity(
        columns: _firstReceiveColumns,
        rows: _firstReceiveRows,
      ),
      DashboardKpiKind.qcPending => const DashboardKpiDetailEntity(
        columns: _qcPendingColumns,
        rows: _qcPendingRows,
      ),
      DashboardKpiKind.articleCount => const DashboardKpiDetailEntity(
        columns: _articleCountColumns,
        rows: _articleCountRows,
      ),
      DashboardKpiKind.empCount => const DashboardKpiDetailEntity(
        columns: _empCountColumns,
        rows: _empCountRows,
      ),
    };
  }
}
