import 'package:equatable/equatable.dart';

/// One selectable option in the Brand Specification screen's brand dropdown.
class BrandEntity extends Equatable {
  const BrandEntity({required this.id, required this.name});

  final String id;
  final String name;

  @override
  List<Object?> get props => [id, name];
}
