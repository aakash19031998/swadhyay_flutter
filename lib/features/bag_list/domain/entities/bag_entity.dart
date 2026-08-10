import 'package:equatable/equatable.dart';

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
    this.metal,
    this.designGrossWt,
    this.designNetWt,
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
    this.styleNo,
    this.designCategory,
    this.byy,
    this.bchr,
    this.bno,
    this.bagCmpCd,
    this.spStatus,
    this.seconds,
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

  // Manufacturing instructions (Bag Detail screen). All optional since a
  // bag may not have every field filled in yet.
  final String? metal;
  final double? designGrossWt;
  final double? designNetWt;
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
  final String? styleNo;
  final String? designCategory;

  // Raw bag-barcode components (e.g. "26/I1/55623" -> byy/bchr/bno) — kept
  // as separate fields rather than pre-joined, since the API sends them
  // separately and it's not yet specified how (or whether) they should be
  // displayed together.
  final String? byy;
  final String? bchr;
  final int? bno;

  /// Company/branch code (e.g. "IJ") — sent as `bCoCo` in `BagTimeTracking`.
  final String? bagCmpCd;

  // Seed the productivity timer's initial Start/Pause/Resume state and
  // elapsed time — read only once, the first time `BagTimerController.of`
  // creates that bag's timer (see there); every load after that (a
  // pull-to-refresh, revisiting the screen, ...) leaves an already-running
  // timer alone rather than resetting it back to whatever the list API
  // says right now. `spStatus` names the bag's current state directly:
  // "S" not started, "P" paused, "R" running.
  final String? spStatus;
  final int? seconds;

  final List<DiamondDetailEntity> diamondDetails;
  final List<BagRmSummaryEntity> rmSummary;

  double get totalPoints => designPoints * bagQty;

  /// Returns a copy with the given fields replaced — used to merge
  /// `BagDetailsNew`'s Bag Summary/Manufacturing Instructions data onto the
  /// [BagEntity] the list screen already loaded, once the detail screen's
  /// own fetch resolves.
  BagEntity copyWith({
    int? bagQty,
    String? metal,
    double? designGrossWt,
    double? designNetWt,
    String? designInstr,
    String? custInstr,
    String? stampInstr,
    String? rhodInstr,
    String? diamInstr,
    String? sizeInstr,
    DateTime? delDate,
    String? size,
    String? customer,
    String? poNo,
    String? part,
    int? pieceQty,
    String? styleNo,
    String? designCategory,
    String? locationCode,
    String? byy,
    String? bchr,
    int? bno,
    String? bagCmpCd,
    List<DiamondDetailEntity>? diamondDetails,
    List<BagRmSummaryEntity>? rmSummary,
  }) {
    return BagEntity(
      id: id,
      bagNo: bagNo,
      designNo: designNo,
      imageUrl: imageUrl,
      spStatus: spStatus,
      seconds: seconds,
      locationCode: locationCode ?? this.locationCode,
      department: department,
      filling: filling,
      bagQty: bagQty ?? this.bagQty,
      designPoints: designPoints,
      assignedDate: assignedDate,
      metal: metal ?? this.metal,
      designGrossWt: designGrossWt ?? this.designGrossWt,
      designNetWt: designNetWt ?? this.designNetWt,
      designInstr: designInstr ?? this.designInstr,
      custInstr: custInstr ?? this.custInstr,
      stampInstr: stampInstr ?? this.stampInstr,
      rhodInstr: rhodInstr ?? this.rhodInstr,
      diamInstr: diamInstr ?? this.diamInstr,
      sizeInstr: sizeInstr ?? this.sizeInstr,
      delDate: delDate ?? this.delDate,
      size: size ?? this.size,
      customer: customer ?? this.customer,
      poNo: poNo ?? this.poNo,
      part: part ?? this.part,
      pieceQty: pieceQty ?? this.pieceQty,
      styleNo: styleNo ?? this.styleNo,
      designCategory: designCategory ?? this.designCategory,
      byy: byy ?? this.byy,
      bchr: bchr ?? this.bchr,
      bno: bno ?? this.bno,
      bagCmpCd: bagCmpCd ?? this.bagCmpCd,
      diamondDetails: diamondDetails ?? this.diamondDetails,
      rmSummary: rmSummary ?? this.rmSummary,
    );
  }

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
        metal,
        designGrossWt,
        designNetWt,
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
        styleNo,
        designCategory,
        byy,
        bchr,
        bno,
        bagCmpCd,
        spStatus,
        seconds,
        diamondDetails,
        rmSummary,
      ];
}
