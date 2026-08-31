/// Navigation payload for `Get.toNamed(AppRoutes.qcBagList, ...)` — opened
/// from a [QcCheckCard] tap, carrying just enough of that employee's
/// already-loaded identity/totals for the header; the bag rows themselves
/// are fetched fresh by [QcBagListController].
class QcBagListArgs {
  const QcBagListArgs({
    required this.empCode,
    required this.empName,
    required this.totalBags,
    required this.totalPieces,
    this.imageUrl,
  });

  final String empCode;
  final String empName;
  final int totalBags;
  final int totalPieces;
  final String? imageUrl;
}
