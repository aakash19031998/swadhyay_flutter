import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/brand_specification_entity.dart';
import '../../domain/usecases/get_brand_specifications_usecase.dart';
import '../../domain/usecases/get_brands_usecase.dart';
import '../../domain/usecases/get_specification_pdf_url_usecase.dart';
import 'brand_pdf_viewer_args.dart';

/// Drives the Brand Specification screen: pick a brand from the sidebar list
/// (loads its rows immediately, no separate submit step), then read its
/// specification rows in a table. [searchQuery] filters [items] purely
/// in-memory (no re-fetch) across all seven fields, the same "load once,
/// filter locally" shape as [BagListController].
class BrandSpecificationController extends GetxController {
  BrandSpecificationController(
    this._getBrandsUseCase,
    this._getBrandSpecificationsUseCase,
    this._getSpecificationPdfUrlUseCase,
  );

  final GetBrandsUseCase _getBrandsUseCase;
  final GetBrandSpecificationsUseCase _getBrandSpecificationsUseCase;
  final GetSpecificationPdfUrlUseCase _getSpecificationPdfUrlUseCase;

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
      AppSnackbar.showFailure,
      (list) => brands.assignAll(list),
    );
    isLoadingBrands.value = false;
  }

  /// Selecting a brand from the sidebar loads its rows immediately — there's
  /// no separate dropdown + Show step in this layout. Re-tapping the
  /// already-selected brand is a no-op rather than re-fetching.
  void selectBrand(BrandEntity brand) {
    if (selectedBrand.value?.id == brand.id) return;
    selectedBrand.value = brand;
    show();
  }

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

  /// Resolves this row's PDF link via `BrandSpecPdf` (Product Id ->
  /// `productId`, SpecHKStyle -> `styleNo`, Short Code -> `custShortCd`),
  /// then opens the resulting `fileUrl` in the in-app PDF viewer (see
  /// [AppRoutes.brandSpecificationPdfViewer]) — never downloaded to a
  /// visible file and never handed off to another app.
  Future<void> viewSpecificationPdf(BrandSpecificationEntity item) async {
    final result = await _getSpecificationPdfUrlUseCase(
      productId: item.productId,
      styleNo: item.specHkStyle,
      custShortCd: item.shortCode,
    );

    result.fold(
      AppSnackbar.showFailure,
      (fileUrl) => Get.toNamed<void>(
        AppRoutes.brandSpecificationPdfViewer,
        arguments: BrandPdfViewerArgs(url: fileUrl, title: item.productId),
      ),
    );
  }
}
