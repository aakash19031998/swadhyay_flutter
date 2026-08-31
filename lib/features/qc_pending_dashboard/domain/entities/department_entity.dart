import 'package:equatable/equatable.dart';

/// One selectable option in the QC Checker screen's "SELECT DEPARTMENT"
/// sidebar.
class DepartmentEntity extends Equatable {
  const DepartmentEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
