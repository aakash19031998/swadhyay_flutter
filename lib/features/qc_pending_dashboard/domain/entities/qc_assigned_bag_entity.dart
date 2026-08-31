import 'package:equatable/equatable.dart';

/// One row of the "QC Bag List" screen — a bag currently assigned to a QC
/// checker's queue, opened from that checker's [QcCheckEntity] card.
class QcAssignedBagEntity extends Equatable {
  const QcAssignedBagEntity({
    required this.bagNo,
    required this.orderNo,
    required this.style,
    required this.process,
    required this.pieces,
    required this.trnId,
    required this.firstRecDate,
    this.imageUrl,
    this.artistCd,
  });

  final String bagNo;
  final String orderNo;
  final String style;
  final String process;
  final int pieces;

  /// `QcPendingBagList`'s `TrnId` — not shown on the card, kept for
  /// completeness/future use (e.g. as the OK/Repair action's transaction
  /// reference).
  final int trnId;

  /// `QcPendingBagList`'s `FirstRecDate` — shown on the card as "First
  /// Received".
  final DateTime firstRecDate;

  /// `QcPendingBagList`'s `3dImage` — falls back to a plain placeholder
  /// swatch (see `_BagThumbnail`) when absent or the URL fails to load.
  final String? imageUrl;

  /// `ArtistCd` — the employee code of the artist who worked the bag.
  /// Only populated by `QCPendingBagSingle` (QC Checker's own bag search),
  /// shown as the card's "Emp" chip; `null` for `QcPendingBagList` entries,
  /// which don't include it.
  final String? artistCd;

  @override
  List<Object?> get props => [
    bagNo,
    orderNo,
    style,
    process,
    pieces,
    trnId,
    firstRecDate,
    imageUrl,
    artistCd,
  ];
}
