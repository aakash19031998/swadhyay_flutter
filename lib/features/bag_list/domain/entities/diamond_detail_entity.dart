import 'package:equatable/equatable.dart';

/// One row of the Bag Detail screen's "Diamond Details" tab. [size] is a
/// display-ready string (e.g. "6.20-6.40 RND") rather than a number — the
/// backend sends a size range plus a shape code, not a single measurement.
/// [weight] is also a string — kept exactly as the API sends it (e.g.
/// "1.4000", trailing zeros included) rather than a `double`, since parsing
/// it as a number would silently drop that formatting.
class DiamondDetailEntity extends Equatable {
  const DiamondDetailEntity({
    required this.srNo,
    required this.itemCode,
    required this.size,
    required this.pcs,
    required this.weight,
    required this.setting,
  });

  final int srNo;
  final String itemCode;
  final String size;
  final int pcs;
  final String weight;
  final String setting;

  @override
  List<Object?> get props => [srNo, itemCode, size, pcs, weight, setting];
}
