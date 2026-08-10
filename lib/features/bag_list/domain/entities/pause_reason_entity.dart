import 'package:equatable/equatable.dart';

/// One selectable option in `PauseReasonMaster`'s list — shown in the Pause
/// dialog's reason dropdown on both the Bag List and Bag Detail screens.
class PauseReasonEntity extends Equatable {
  const PauseReasonEntity({required this.reasonId, required this.reasonDesc});

  final int reasonId;
  final String reasonDesc;

  @override
  List<Object?> get props => [reasonId, reasonDesc];
}
