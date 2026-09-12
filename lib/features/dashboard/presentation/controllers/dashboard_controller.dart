import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/dashboard_artisan_summary_entity.dart';
import '../../domain/entities/dashboard_department_entity.dart';
import '../../domain/entities/dashboard_metal_loss_entity.dart';
import '../../domain/entities/dashboard_production_entity.dart';
import '../../domain/entities/dashboard_quality_inspection_entity.dart';
import '../../domain/entities/dashboard_target_achievement_entity.dart';
import '../../domain/usecases/get_dashboard_departments_usecase.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

/// Drives the Dashboard screen: a department switcher on the left, and a
/// summary (Active Artisans, Today's Production, Quality Inspection,
/// Target and Achievement, Metal Loss) for whichever department is selected
/// on the right. Auto-selects the first department on load so the screen
/// isn't empty on first open.
class DashboardController extends GetxController {
  DashboardController(this._getDepartmentsUseCase, this._getSummaryUseCase);

  final GetDashboardDepartmentsUseCase _getDepartmentsUseCase;
  final GetDashboardSummaryUseCase _getSummaryUseCase;

  final TextEditingController searchController = TextEditingController();

  final RxList<DashboardDepartmentEntity> departments =
      <DashboardDepartmentEntity>[].obs;
  final Rxn<DashboardDepartmentEntity> selectedDepartment =
      Rxn<DashboardDepartmentEntity>();
  final RxBool isLoadingDepartments = true.obs;
  final RxString query = ''.obs;

  final Rxn<DashboardArtisanSummaryEntity> artisans =
      Rxn<DashboardArtisanSummaryEntity>();
  final Rxn<DashboardProductionEntity> production =
      Rxn<DashboardProductionEntity>();
  final Rxn<DashboardQualityInspectionEntity> qualityInspection =
      Rxn<DashboardQualityInspectionEntity>();
  final Rxn<DashboardTargetAchievementEntity> targetAchievement =
      Rxn<DashboardTargetAchievementEntity>();
  final Rxn<DashboardMetalLossEntity> metalLoss =
      Rxn<DashboardMetalLossEntity>();
  final RxBool isLoadingSummary = false.obs;

  /// Full (unfiltered) department snapshot — [query] filters this purely
  /// in-memory, same "load once, filter locally" shape used elsewhere in
  /// this app (e.g. `BagListController`).
  List<DashboardDepartmentEntity> _allDepartments = const [];

  @override
  void onInit() {
    super.onInit();
    _loadDepartments();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadDepartments() async {
    isLoadingDepartments.value = true;
    final result = await _getDepartmentsUseCase();
    result.fold(AppSnackbar.showFailure, (data) {
      _allDepartments = data;
      departments.assignAll(data);
      if (data.isNotEmpty) selectDepartment(data.first);
    });
    isLoadingDepartments.value = false;
  }

  void selectDepartment(DashboardDepartmentEntity department) {
    if (selectedDepartment.value?.id == department.id) return;
    selectedDepartment.value = department;
    _loadSummary(department.id);
  }

  Future<void> _loadSummary(String departmentId) async {
    isLoadingSummary.value = true;
    final result = await _getSummaryUseCase(departmentId: departmentId);
    result.fold(AppSnackbar.showFailure, (summary) {
      artisans.value = summary.artisans;
      production.value = summary.production;
      qualityInspection.value = summary.qualityInspection;
      targetAchievement.value = summary.targetAchievement;
      metalLoss.value = summary.metalLoss;
    });
    isLoadingSummary.value = false;
  }

  void onQueryChanged(String value) {
    query.value = value;
    final String needle = value.trim().toLowerCase();
    departments.assignAll(
      needle.isEmpty
          ? _allDepartments
          : _allDepartments.where(
              (department) => department.name.toLowerCase().contains(needle),
            ),
    );
  }
}
