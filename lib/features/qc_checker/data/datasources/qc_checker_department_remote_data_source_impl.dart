import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../../qc_pending_dashboard/data/models/dia_qc_checker_model.dart';
import '../../../qc_pending_dashboard/domain/entities/department_entity.dart';
import '../../domain/entities/qc_checker_department_list_entity.dart';
import 'qc_checker_department_data_source.dart';

/// `QCDepartmentN`, called with `empCd`+`appVersion` (POST) to return the
/// QC Checker screen's own department list (`data.QcDeptList`) AND its
/// "Diamond QC Checker" dropdown options (`data.DiaQcList`) in one call —
/// kept separate from the QC Pending Dashboard's `QCDeptList`/`QCRepairList`
/// (see `QcDepartmentRemoteDataSourceImpl`/`QcRepairListRemoteDataSourceImpl`),
/// neither of which this screen calls.
class QcCheckerDepartmentRemoteDataSourceImpl
    implements QcCheckerDepartmentDataSource {
  QcCheckerDepartmentRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QcCheckerDepartmentListEntity> getDepartments({
    required String empCd,
  }) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient
          .post<Map<String, dynamic>>(
            ApiEndpoints.qcCheckerDeptList,
            data: {'empCd': empCd, 'appVersion': AppVersion.versionName},
          );

      final Map<String, dynamic> body =
          response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool
          ? rawStatus
          : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(
          message: body['message'] as String? ?? 'Unable to load departments',
        );
      }

      final Map<String, dynamic> data =
          body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};

      final List<dynamic> deptList =
          data['QcDeptList'] as List<dynamic>? ?? const [];
      final List<DepartmentEntity> departments = [
        for (final entry in deptList)
          if (((entry as Map<String, dynamic>)['deptCd'] as String?)
                  ?.isNotEmpty ??
              false)
            DepartmentEntity(
              id: entry['deptCd'] as String,
              name: entry['deptCd'] as String,
            ),
      ];

      final List<dynamic> diaQcList =
          data['DiaQcList'] as List<dynamic>? ?? const [];
      final List<DiaQcCheckerModel> diaQcCheckers = [
        for (final entry in diaQcList)
          DiaQcCheckerModel.fromJson(entry as Map<String, dynamic>),
      ];

      return QcCheckerDepartmentListEntity(
        departments: departments,
        diaQcCheckers: diaQcCheckers,
      );
    }, (_) => 'Unable to load departments');
  }
}
