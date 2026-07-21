import 'package:equatable/equatable.dart';

import 'bag_media_entity.dart';

class BagEntity extends Equatable {
  const BagEntity({
    required this.id,
    required this.bagNo,
    required this.designNo,
    required this.locationCode,
    required this.filling,
    required this.bagQty,
    required this.designPoints,
    required this.assignedDate,
    this.imageUrl,
    this.media = const [],
  });

  final String id;
  final String bagNo;
  final String designNo;
  final String? imageUrl;
  final String locationCode;
  final String filling;
  final int bagQty;
  final double designPoints;
  final DateTime assignedDate;
  final List<BagMediaEntity> media;

  double get totalPoints => designPoints * bagQty;

  @override
  List<Object?> get props => [
        id,
        bagNo,
        designNo,
        imageUrl,
        locationCode,
        filling,
        bagQty,
        designPoints,
        assignedDate,
        media,
      ];
}
