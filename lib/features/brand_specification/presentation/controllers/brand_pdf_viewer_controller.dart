import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:pdfx/pdfx.dart';

import '../../../../core/constants/app_strings.dart';

/// Fetches the PDF's bytes into memory and renders them with [PdfViewPinch]
/// — nothing is ever written to a downloads-visible file and no external
/// app is handed the document, unlike the earlier `OpenFilex`-based flow.
class BrandPdfViewerController extends GetxController {
  BrandPdfViewerController({required this.url, required this.title});

  final String url;
  final String title;

  final RxBool isLoading = true.obs;
  final RxnString errorMessage = RxnString();
  PdfControllerPinch? pdfController;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = null;
    pdfController?.dispose();
    pdfController = null;

    try {
      final Response<List<int>> response = await Dio().get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      final Uint8List bytes = Uint8List.fromList(response.data ?? const []);
      pdfController = PdfControllerPinch(document: PdfDocument.openData(bytes));
    } catch (_) {
      errorMessage.value = AppStrings.pdfOpenFailed;
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    pdfController?.dispose();
    super.onClose();
  }
}
