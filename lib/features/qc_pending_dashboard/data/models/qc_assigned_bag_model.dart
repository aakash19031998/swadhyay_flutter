import '../../domain/entities/qc_assigned_bag_entity.dart';

class QcAssignedBagModel extends QcAssignedBagEntity {
  const QcAssignedBagModel({
    required super.bagNo,
    required super.orderNo,
    required super.style,
    required super.process,
    required super.pieces,
    required super.trnId,
    required super.firstRecDate,
    super.imageUrl,
    super.artistCd,
  });

  /// One `QcPendingBagList`/`QCPendingBagSingle` entry — `ArtistCd` is only
  /// present in the latter.
  factory QcAssignedBagModel.fromJson(Map<String, dynamic> json) {
    return QcAssignedBagModel(
      bagNo: json['Bag'] as String? ?? '',
      orderNo: json['ODNO'] as String? ?? '',
      style: json['Design'] as String? ?? '',
      process: json['Process'] as String? ?? '',
      pieces: (json['Pcs'] as num?)?.toInt() ?? 0,
      trnId: (json['TrnId'] as num?)?.toInt() ?? 0,
      firstRecDate:
          DateTime.tryParse(json['FirstRecDate'] as String? ?? '') ??
          DateTime.now(),
      imageUrl: json['3dImage'] as String?,
      artistCd: (json['ArtistCd'] as num?)?.toString(),
    );
  }
}
