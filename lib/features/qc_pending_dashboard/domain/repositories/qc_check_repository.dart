import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/qc_assigned_bag_entity.dart';
import '../entities/qc_department_list_entity.dart';
import '../entities/qc_emp_list_entity.dart';
import '../entities/qc_repair_checklist_item_entity.dart';
import '../entities/qc_repair_qty_entity.dart';
import '../entities/qc_submit_result_entity.dart';

abstract class QcCheckRepository {
  /// Always live (`DeptQCPendingEmpList`) regardless of
  /// `AppConfig.useMockData` — see `QcEmpListDataSource`.
  Future<Either<Failure, QcEmpListEntity>> getChecks({required String deptId});

  /// Always live (`QCDeptList`) regardless of `AppConfig.useMockData` —
  /// see `QcDepartmentDataSource`.
  Future<Either<Failure, QcDepartmentListEntity>> getDepartments({required String empCd});

  /// Always live (`QcPendingBagList`) regardless of `AppConfig.useMockData`
  /// — see `QcBagListDataSource`.
  Future<Either<Failure, List<QcAssignedBagEntity>>> getAssignedBags({required String empCode});

  /// Always live (`QCRepairList`) regardless of `AppConfig.useMockData` —
  /// see `QcRepairListDataSource`. `schr` is the tapped bag's `Process`.
  Future<Either<Failure, List<QcRepairChecklistItemEntity>>> getRepairChecklist({
    required String schr,
    required String empCd,
  });

  /// Always live (`BagFinalReceive`) regardless of `AppConfig.useMockData`
  /// — see `QcActionSubmitDataSource`. Submitted from the QC OK/Repair
  /// popup's Submit tap.
  Future<Either<Failure, QcSubmitResultEntity>> submitAction({
    required String action,
    required String trnId,
    required String bagNo,
    required String empCd,
    required String userEmpCd,
    required String process,
    required String diaQcCd,
    required List<QcRepairQtyEntity> repairList,
  });
}
