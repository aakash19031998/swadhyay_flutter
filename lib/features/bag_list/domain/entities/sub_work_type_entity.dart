import 'package:equatable/equatable.dart';

/// One `SubWorkType` option — the Work dropdown's choices for whichever
/// Work Type the user just selected.
class SubWorkTypeEntity extends Equatable {
  const SubWorkTypeEntity({required this.workId, required this.work});

  final int workId;
  final String work;

  @override
  List<Object?> get props => [workId, work];
}
