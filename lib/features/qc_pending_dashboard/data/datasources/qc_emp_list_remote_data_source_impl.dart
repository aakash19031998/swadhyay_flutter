import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/data_source_guard.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/qc_emp_list_entity.dart';
import '../models/dia_qc_checker_model.dart';
import '../models/qc_check_model.dart';
import 'qc_emp_list_data_source.dart';

/// `DeptQCPendingEmpList`, called with `deptCd`+`appVersion` (POST) —
/// `deptCd` is the currently selected department from the sidebar. Returns
/// the employee grid (`data.EmpList`) and the "Diamond QC Checker" master
/// list (`data.DiaQcList`) together.
class QcEmpListRemoteDataSourceImpl implements QcEmpListDataSource {
  QcEmpListRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QcEmpListEntity> getEmpList({required String deptCd}) {
    return wrapDioErrors(() async {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.deptQcPendingEmpList,
        data: {
          'deptCd': deptCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load employees');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final List<dynamic> empList = data['EmpList'] as List<dynamic>? ?? const [];
      final List<dynamic> diaQcJson = data['DiaQcList'] as List<dynamic>? ?? const [];

      return QcEmpListEntity(
        checks: [
          for (final entry in empList) QcCheckModel.fromJson(entry as Map<String, dynamic>),
        ],
        diaQcList: [
          for (final entry in diaQcJson) DiaQcCheckerModel.fromJson(entry as Map<String, dynamic>),
        ],
      );
    }, (_) => 'Unable to load employees');
  }
}
