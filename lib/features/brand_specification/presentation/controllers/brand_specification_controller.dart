import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../../domain/usecases/get_brand_specifications_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import 'brand_pdf_viewer_args.dart';

/// Drives the Brand Specification screen: pick a brand from the dropdown,
/// tap Show, then read its specification rows in a table. [searchQuery]
/// filters [items] purely in-memory (no re-fetch) across all seven fields,
/// the same "load once, filter locally" shape as [BagListController].
class BrandSpecificationController extends GetxController {
  BrandSpecificationController(this._getBrandsUseCase, this._getBrandSpecificationsUseCase);

  final GetBrandsUseCase _getBrandsUseCase;
  final GetBrandSpecificationsUseCase _getBrandSpecificationsUseCase;

  final RxList<BrandEntity> brands = <BrandEntity>[].obs;
  final Rxn<BrandEntity> selectedBrand = Rxn<BrandEntity>();
  final RxList<BrandSpecificationEntity> items = <BrandSpecificationEntity>[].obs;

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;

  final RxBool isLoadingBrands = true.obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  final RxBool hasSearched = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBrands();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> _loadBrands() async {
    isLoadingBrands.value = true;
    final result = await _getBrandsUseCase();
    result.fold(
      (failure) => AppSnackbar.show(title: AppStrings.alertWarning, message: failure.message, isSuccess: false),
      (list) => brands.assignAll(list),
    );
    isLoadingBrands.value = false;
  }

  void onBrandChanged(BrandEntity? brand) => selectedBrand.value = brand;

  void onSearchChanged(String value) => searchQuery.value = value;

  /// [items] filtered by [searchQuery] across every column — read inside an
  /// `Obx`, this pulls in both as dependencies since the reads happen
  /// during the same build, exactly like `BagListController`'s query
  /// filter.
  List<BrandSpecificationEntity> get filteredItems {
    final String query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return items;
    return items
        .where(
          (item) =>
              item.productId.toLowerCase().contains(query) ||
              item.specHkStyle.toLowerCase().contains(query) ||
              item.custMaterial.toLowerCase().contains(query) ||
              item.specStyleKt.toLowerCase().contains(query) ||
              item.specStyleCol.toLowerCase().contains(query) ||
              item.specCustomer.toLowerCase().contains(query) ||
              item.shortCode.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> show() async {
    final BrandEntity? brand = selectedBrand.value;
    if (brand == null) {
      AppSnackbar.show(title: AppStrings.alertWarning, message: AppStrings.selectBrandRequired, isSuccess: false);
      return;
    }

    isLoading.value = true;
    errorMessage.value = null;
    hasSearched.value = true;
    searchController.clear();
    searchQuery.value = '';

    final result = await _getBrandSpecificationsUseCase(brandId: brand.id);
    result.fold(
      (failure) => errorMessage.value = failure.message,
      (list) => items.assignAll(list),
    );

    isLoading.value = false;
  }

  /// Opens this row's specification sheet in the in-app PDF viewer (see
  /// [AppRoutes.brandSpecificationPdfViewer]) — never downloaded to a
  /// visible file and never handed off to another app.
  void viewSpecificationPdf(BrandSpecificationEntity item) {
    if (item.pdfUrl.isEmpty) {
      AppSnackbar.show(title: AppStrings.alertWarning, message: AppStrings.pdfUnavailable, isSuccess: false);
      return;
    }

    Get.toNamed<void>(
      AppRoutes.brandSpecificationPdfViewer,
      arguments: BrandPdfViewerArgs(url: item.pdfUrl, title: item.productId),
    );
  }
}
