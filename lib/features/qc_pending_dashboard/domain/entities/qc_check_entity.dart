import 'package:equatable/equatable.dart';

/// One employee card on the QC Checker screen's grid, pending QC for the
/// currently selected department.
class QcCheckEntity extends Equatable {
  const QcCheckEntity({
    required this.empCode,
    required this.empName,
    required this.totalBags,
    required this.totalPieces,
    this.imageUrl,
  });

  final String empCode;
  final String empName;
  final int totalBags;
  final int totalPieces;
  final String? imageUrl;

  @override
  List<Object?> get props => [empCode, empName, totalBags, totalPieces, imageUrl];
}
