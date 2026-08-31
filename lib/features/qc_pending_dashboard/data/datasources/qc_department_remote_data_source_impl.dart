import 'package:dio/dio.dart';

import '../../../../core/config/app_version.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/department_entity.dart';
import '../../domain/entities/qc_department_list_entity.dart';
import 'qc_department_data_source.dart';

/// `QCDeptList`, called here with `empCd`+`appVersion` (POST) to return
/// the employee's own QC department list (`data.dept_list`'s `DeptCd`
/// entries) plus `data.auto_update` ("Y"/"N"), which gates whether the QC
/// Checker grid should auto-refresh `DeptQCPendingEmpList` every 60s.
class QcDepartmentRemoteDataSourceImpl implements QcDepartmentDataSource {
  QcDepartmentRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<QcDepartmentListEntity> getDepartments({required String empCd}) async {
    try {
      final Response<Map<String, dynamic>> response = await _apiClient.post<Map<String, dynamic>>(
        ApiEndpoints.qcDeptList,
        data: {
          'empCd': empCd,
          'appVersion': AppVersion.versionName,
        },
      );

      final Map<String, dynamic> body = response.data ?? const <String, dynamic>{};
      final dynamic rawStatus = body['status'];
      final bool status = rawStatus is bool ? rawStatus : (rawStatus as String? ?? '').toLowerCase() == 'true';
      if (!status) {
        throw ServerException(message: body['message'] as String? ?? 'Unable to load departments');
      }

      final Map<String, dynamic> data = body['data'] as Map<String, dynamic>? ?? const <String, dynamic>{};
      final List<dynamic> deptList = data['dept_list'] as List<dynamic>? ?? const [];
      final List<DepartmentEntity> departments = [
        for (final entry in deptList)
          if (((entry as Map<String, dynamic>)['DeptCd'] as String?)?.isNotEmpty ?? false)
            DepartmentEntity(id: entry['DeptCd'] as String, name: entry['DeptCd'] as String),
      ];
      final bool autoUpdate = (data['auto_update'] as String? ?? 'N').toUpperCase() == 'Y';

      return QcDepartmentListEntity(departments: departments, autoUpdate: autoUpdate);
    } on DioException catch (e) {
      throw ServerException(message: 'Unable to load departments', statusCode: e.response?.statusCode);
    }
  }
}
