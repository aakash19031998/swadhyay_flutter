import 'package:equatable/equatable.dart';

enum QcResult { pass, fail, rework }

class QcCheckEntity extends Equatable {
  const QcCheckEntity({
    required this.id,
    required this.bagNo,
    required this.designNo,
    required this.checkedBy,
    required this.checkedAt,
    required this.result,
    this.remarks,
  });

  final String id;
  final String bagNo;
  final String designNo;
  final String checkedBy;
  final DateTime checkedAt;
  final QcResult result;
  final String? remarks;

  @override
  List<Object?> get props => [id, bagNo, designNo, checkedBy, checkedAt, result, remarks];
}
