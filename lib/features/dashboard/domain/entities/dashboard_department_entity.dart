import 'package:equatable/equatable.dart';

/// One entry in the department switcher sidebar. [floorLabel] (e.g.
/// "Floor #1") is shown as trailing text when this department isn't the
/// selected one; the selected row shows an "ACTIVE" pill instead.
class DashboardDepartmentEntity extends Equatable {
  const DashboardDepartmentEntity({
    required this.id,
    required this.name,
    required this.floorLabel,
  });

  final String id;
  final String name;
  final String floorLabel;

  @override
  List<Object?> get props => [id, name, floorLabel];
}
