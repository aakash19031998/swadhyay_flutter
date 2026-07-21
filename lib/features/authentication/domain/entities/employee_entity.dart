import 'package:equatable/equatable.dart';

/// The authenticated employee's identity and shift-punch details, shown in
/// the drawer header and used across every screen that needs "who is
/// signed in". The profile-only fields (department, contact info, address,
/// work efficiency) are only ever read on the Profile screen.
class EmployeeEntity extends Equatable {
  const EmployeeEntity({
    required this.empCode,
    required this.name,
    this.avatarUrl,
    this.punchInAt,
    this.department,
    this.contactNumber,
    this.alternateContactNumber,
    this.address,
    this.workEfficiency,
  });

  final String empCode;
  final String name;
  final String? avatarUrl;
  final DateTime? punchInAt;
  final String? department;
  final String? contactNumber;
  final String? alternateContactNumber;
  final String? address;
  final String? workEfficiency;

  @override
  List<Object?> get props => [
        empCode,
        name,
        avatarUrl,
        punchInAt,
        department,
        contactNumber,
        alternateContactNumber,
        address,
        workEfficiency,
      ];
}
