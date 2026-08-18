import 'package:equatable/equatable.dart';

/// One row of a selected brand's specification list.
class BrandSpecificationEntity extends Equatable {
  const BrandSpecificationEntity({
    required this.productId,
    required this.specHkStyle,
    required this.custMaterial,
    required this.specStyleKt,
    required this.specStyleCol,
    required this.specCustomer,
    required this.shortCode,
    required this.pdfUrl,
  });

  final String productId;
  final String specHkStyle;
  final String custMaterial;
  final String specStyleKt;
  final String specStyleCol;
  final String specCustomer;
  final String shortCode;

  /// Direct download link for this row's specification sheet — tapping the
  /// row downloads and opens it via the device's default PDF viewer.
  final String pdfUrl;

  @override
  List<Object?> get props => [
        productId,
        specHkStyle,
        custMaterial,
        specStyleKt,
        specStyleCol,
        specCustomer,
        shortCode,
        pdfUrl,
      ];
}
