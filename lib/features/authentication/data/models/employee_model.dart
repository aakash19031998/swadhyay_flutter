import 'package:intl/intl.dart';

import '../../domain/entities/employee_entity.dart';

/// JSON-serializable [EmployeeEntity]. Kept as a subtype (not a wrapper) so
/// it can be passed anywhere an [EmployeeEntity] is expected without an
/// extra mapping step.
class EmployeeModel extends EmployeeEntity {
  const EmployeeModel({
    required super.empCode,
    required super.name,
    super.avatarUrl,
    super.punchInAt,
    super.department,
    super.deptCode,
    super.employeeType,
    super.contactNumber,
    super.alternateContactNumber,
    super.address,
    super.workEfficiency,
    super.companyCode,
    super.totalHoursTillDate,
    super.otHours,
    super.presentDays,
  });

  /// Parses the `data` object of the `CheckLogInNew` login response.
  factory EmployeeModel.fromApiJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empCode: json['EmpCd'] as String? ?? '',
      name: json['EmpNm'] as String? ?? '',
      avatarUrl: json['EmpImg'] as String?,
      punchInAt: _parsePunchInTime(json['InTm'] as String?),
      department: json['DeptName'] as String?,
      deptCode: json['DeptCd'] as String?,
      employeeType: json['EmpType'] as String?,
      companyCode: json['CmpCd'] as String?,
      totalHoursTillDate: (json['TotalHrs'] as num?)?.toString(),
      otHours: (json['OTHrs'] as num?)?.toString(),
      presentDays: (json['PDays'] as num?)?.round(),
    );
  }

  static DateTime? _parsePunchInTime(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return DateFormat('dd/MM/yyyy HH:mm').parseStrict(raw);
    } catch (_) {
      return null;
    }
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empCode: json['empCode'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      punchInAt: json['punchInAt'] == null ? null : DateTime.parse(json['punchInAt'] as String),
      department: json['department'] as String?,
      deptCode: json['deptCode'] as String?,
      employeeType: json['employeeType'] as String?,
      contactNumber: json['contactNumber'] as String?,
      alternateContactNumber: json['alternateContactNumber'] as String?,
      address: json['address'] as String?,
      workEfficiency: json['workEfficiency'] as String?,
      companyCode: json['companyCode'] as String?,
      totalHoursTillDate: json['totalHoursTillDate'] as String?,
      otHours: json['otHours'] as String?,
      presentDays: json['presentDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empCode': empCode,
      'name': name,
      'avatarUrl': avatarUrl,
      'punchInAt': punchInAt?.toIso8601String(),
      'department': department,
      'deptCode': deptCode,
      'employeeType': employeeType,
      'contactNumber': contactNumber,
      'alternateContactNumber': alternateContactNumber,
      'address': address,
      'workEfficiency': workEfficiency,
      'companyCode': companyCode,
      'totalHoursTillDate': totalHoursTillDate,
      'otHours': otHours,
      'presentDays': presentDays,
    };
  }
}
