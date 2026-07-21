import 'package:equatable/equatable.dart';

class SkippedBagEntity extends Equatable {
  const SkippedBagEntity({
    required this.id,
    required this.bagNo,
    required this.reason,
    required this.skippedAt,
  });

  final String id;
  final String bagNo;
  final String reason;
  final DateTime skippedAt;

  @override
  List<Object?> get props => [id, bagNo, reason, skippedAt];
}
