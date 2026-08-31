import '../../domain/entities/brand_specification_entity.dart';

class BrandSpecificationModel extends BrandSpecificationEntity {
  const BrandSpecificationModel({
    required super.productId,
    required super.specHkStyle,
    required super.custMaterial,
    required super.specStyleKt,
    required super.specStyleCol,
    required super.specCustomer,
    required super.shortCode,
    required super.pdfUrl,
  });

  /// `BrandSpecData` sends no PDF link for a row, so [pdfUrl] is left
  /// empty — the view already treats an empty `pdfUrl` as "no specification
  /// sheet available" rather than a broken link.
  ///
  /// `BrandSpecData`'s field casing isn't consistent between calls — one
  /// live response used `productid`/`specHKStyle`/`custMaterial`/
  /// `specStyleKT`/`specStyleCol`/`specCustomer`, another used
  /// `Productid`/`SpecHKStyle`/`CustMaterial`/`SpecStyleKT`/`SpecStyleCol`/
  /// `SpecCustomer` (only `shortcode` stayed lowercase both times) — so
  /// each field checks both casings rather than trusting just one.
  factory BrandSpecificationModel.fromJson(Map<String, dynamic> json) {
    return BrandSpecificationModel(
      productId: _field(json, const ['productid', 'Productid']),
      specHkStyle: _field(json, const ['specHKStyle', 'SpecHKStyle']),
      custMaterial: _field(json, const ['custMaterial', 'CustMaterial']),
      specStyleKt: _field(json, const ['specStyleKT', 'SpecStyleKT']),
      specStyleCol: _field(json, const ['specStyleCol', 'SpecStyleCol']),
      specCustomer: _field(json, const ['specCustomer', 'SpecCustomer']),
      shortCode: _field(json, const ['shortcode', 'Shortcode', 'ShortCode']),
      pdfUrl: '',
    );
  }

  /// Returns the value of the first [keys] entry actually present in
  /// [json] — not just the first non-null one, so a field that's
  /// legitimately an empty string under the correct key is still returned
  /// as-is rather than skipped in favor of a later candidate.
  static String _field(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key] as String? ?? '';
    }
    return '';
  }
}
