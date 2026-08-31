import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/qc_assigned_bag_entity.dart';
import '../../domain/entities/qc_department_list_entity.dart';
import '../../domain/entities/qc_emp_list_entity.dart';
import '../../domain/entities/qc_repair_checklist_item_entity.dart';
import '../../domain/entities/qc_repair_qty_entity.dart';
import '../../domain/entities/qc_submit_result_entity.dart';
import '../../domain/repositories/qc_check_repository.dart';
import '../datasources/qc_action_submit_data_source.dart';
import '../datasources/qc_bag_list_data_source.dart';
import '../datasources/qc_department_data_source.dart';
import '../datasources/qc_emp_list_data_source.dart';
import '../datasources/qc_repair_list_data_source.dart';

class QcCheckRepositoryImpl implements QcCheckRepository {
  QcCheckRepositoryImpl(
    this._departmentDataSource,
    this._empListDataSource,
    this._bagListDataSource,
    this._repairListDataSource,
    this._actionSubmitDataSource,
  );

  final QcDepartmentDataSource _departmentDataSource;
  final QcEmpListDataSource _empListDataSource;
  final QcBagListDataSource _bagListDataSource;
  final QcRepairListDataSource _repairListDataSource;
  final QcActionSubmitDataSource _actionSubmitDataSource;

  @override
  Future<Either<Failure, QcEmpListEntity>> getChecks({required String deptId}) async {
    try {
      final checks = await _empListDataSource.getEmpList(deptCd: deptId);
      return Right(checks);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QcDepartmentListEntity>> getDepartments({required String empCd}) async {
    try {
      final departments = await _departmentDataSource.getDepartments(empCd: empCd);
      return Right(departments);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<QcAssignedBagEntity>>> getAssignedBags({required String empCode}) async {
    try {
      final bags = await _bagListDataSource.getBagList(empCd: empCode);
      return Right(bags);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, List<QcRepairChecklistItemEntity>>> getRepairChecklist({
    required String schr,
    required String empCd,
  }) async {
    try {
      final repairList = await _repairListDataSource.getRepairList(schr: schr, empCd: empCd);
      return Right(repairList);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, QcSubmitResultEntity>> submitAction({
    required String action,
    required String trnId,
    required String bagNo,
    required String empCd,
    required String userEmpCd,
    required String process,
    required String diaQcCd,
    required List<QcRepairQtyEntity> repairList,
  }) async {
    try {
      final result = await _actionSubmitDataSource.submit(
        action: action,
        trnId: trnId,
        bagNo: bagNo,
        empCd: empCd,
        userEmpCd: userEmpCd,
        process: process,
        diaQcCd: diaQcCd,
        repairList: repairList,
      );
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    }
  }
}
