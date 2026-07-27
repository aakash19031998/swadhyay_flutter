import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

/// Drives the bag scanner screen: a live QR/barcode reader on the
/// front-facing camera only (no rear-camera fallback). The first
/// successfully-decoded value (QR or 1D barcode) closes the screen,
/// returning that value to whoever pushed it (see [AppRoutes.bagScanner]'s
/// caller in `bag_list_view.dart`, which feeds it into the bag list's
/// search).
class BagScannerController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    facing: CameraFacing.front,
    detectionSpeed: DetectionSpeed.noDuplicates,
    // Explicit rather than relying on the "empty = all formats" default —
    // makes it clear this reads 1D barcodes (EAN/UPC/Code128/...) as well
    // as QR, not just QR.
    formats: const [
      BarcodeFormat.qrCode,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.codabar,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.itf14,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.dataMatrix,
      BarcodeFormat.aztec,
      BarcodeFormat.pdf417,
    ],
    // Front cameras are usually fixed-focus and lower-res than the rear
    // camera, which QR tolerates (large, error-corrected blocks) but 1D
    // barcodes (thin parallel lines) don't — a sharper capture plus
    // digital auto-zoom on a far/small code meaningfully improves barcode
    // decode success without changing the front-camera-only requirement.
    cameraResolution: const Size(1920, 1080),
    autoZoom: true,
  );

  bool _hasReturned = false;

  void onDetect(BarcodeCapture capture) {
    if (_hasReturned || capture.barcodes.isEmpty) return;

    final String? value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;

    _hasReturned = true;
    Get.back(result: value);
  }

  Future<void> openSettings() => openAppSettings();

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
