import 'package:equatable/equatable.dart';

import 'bag_media_entity.dart';
import 'bag_rm_summary_entity.dart';
import 'diamond_detail_entity.dart';

class BagEntity extends Equatable {
  const BagEntity({
    required this.id,
    required this.bagNo,
    required this.designNo,
    required this.locationCode,
    required this.department,
    required this.filling,
    required this.bagQty,
    required this.designPoints,
    required this.assignedDate,
    this.imageUrl,
    this.media = const [],
    this.metal,
    this.designGrossWt,
    this.extra,
    this.diamondWax,
    this.extra2,
    this.designInstr,
    this.custInstr,
    this.stampInstr,
    this.rhodInstr,
    this.diamInstr,
    this.sizeInstr,
    this.delDate,
    this.size,
    this.customer,
    this.poNo,
    this.part,
    this.pieceQty,
    this.diamondDetails = const [],
    this.rmSummary = const [],
  });

  final String id;
  final String bagNo;
  final String designNo;
  final String? imageUrl;
  final String locationCode;

  /// Which stage of the production process this bag is currently in
  /// (Filling, Setting, Polishing, Casting, ...) — moves with the bag, so
  /// it must come from data, never a hardcoded label.
  final String department;
  final String filling;
  final int bagQty;
  final double designPoints;
  final DateTime assignedDate;
  final List<BagMediaEntity> media;

  // Manufacturing instructions (Bag Detail screen). All optional since a
  // bag may not have every field filled in yet.
  final String? metal;
  final double? designGrossWt;
  final String? extra;
  final String? diamondWax;
  final String? extra2;
  final String? designInstr;
  final String? custInstr;
  final String? stampInstr;
  final String? rhodInstr;
  final String? diamInstr;
  final String? sizeInstr;

  // Bag summary sidebar (Bag Detail screen).
  final DateTime? delDate;
  final String? size;
  final String? customer;
  final String? poNo;
  final String? part;
  final int? pieceQty;

  final List<DiamondDetailEntity> diamondDetails;
  final List<BagRmSummaryEntity> rmSummary;

  double get totalPoints => designPoints * bagQty;

  @override
  List<Object?> get props => [
        id,
        bagNo,
        designNo,
        imageUrl,
        locationCode,
        department,
        filling,
        bagQty,
        designPoints,
        assignedDate,
        media,
        metal,
        designGrossWt,
        extra,
        diamondWax,
        extra2,
        designInstr,
        custInstr,
        stampInstr,
        rhodInstr,
        diamInstr,
        sizeInstr,
        delDate,
        size,
        customer,
        poNo,
        part,
        pieceQty,
        diamondDetails,
        rmSummary,
      ];
}
