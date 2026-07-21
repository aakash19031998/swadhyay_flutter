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
    super.contactNumber,
    super.alternateContactNumber,
    super.address,
    super.workEfficiency,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      empCode: json['empCode'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      punchInAt: json['punchInAt'] == null ? null : DateTime.parse(json['punchInAt'] as String),
      department: json['department'] as String?,
      contactNumber: json['contactNumber'] as String?,
      alternateContactNumber: json['alternateContactNumber'] as String?,
      address: json['address'] as String?,
      workEfficiency: json['workEfficiency'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'empCode': empCode,
      'name': name,
      'avatarUrl': avatarUrl,
      'punchInAt': punchInAt?.toIso8601String(),
      'department': department,
      'contactNumber': contactNumber,
      'alternateContactNumber': alternateContactNumber,
      'address': address,
      'workEfficiency': workEfficiency,
    };
  }
}
