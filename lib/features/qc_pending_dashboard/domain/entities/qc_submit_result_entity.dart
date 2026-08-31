import 'package:equatable/equatable.dart';

/// `BagFinalReceive`'s response — [success] mirrors its `status` and
/// [message] is shown on the app snackbar either way (a `status: false`
/// here is an expected, non-exceptional outcome — e.g. "already
/// received" — not a [Failure]; only an actual network/server error
/// reaches that path instead).
class QcSubmitResultEntity extends Equatable {
  const QcSubmitResultEntity({required this.success, required this.message});

  final bool success;
  final String message;

  @override
  List<Object?> get props => [success, message];
}
