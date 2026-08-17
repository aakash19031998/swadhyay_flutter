import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../services/app_update_controller.dart';

/// Force-update dialog — shown by [ForceUpdateGuard] the moment any API
/// response signals the installed app is behind the backend's
/// `minAppVersion`. Non-dismissible on purpose: no barrier tap, no back
/// button, no close action — the only way out is to update.
///
/// Visual design as specified: icon badge, version pill, title,
/// description, and a single "Download & Install" action — wired here to
/// [AppUpdateController] for the actual download-progress/install flow
/// instead of a static demo string.
class UpdateCard extends StatelessWidget {
  const UpdateCard({required this.message, required this.minAppVersion, required this.updateUrl, super.key});

  final String message;
  final String minAppVersion;
  final String updateUrl;

  @override
  Widget build(BuildContext context) {
    final AppUpdateController controller = Get.find<AppUpdateController>();

    return PopScope(
      canPop: false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 380),
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: const Color(0xFFF0F2F5),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2B308B).withValues(alpha: 0.07),
                  blurRadius: 45,
                  offset: const Offset(0, 20),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon Box
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.file_download_outlined,
                    color: Color(0xFF2B308B),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),

                // Version Pill Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    'v$minAppVersion available'.toUpperCase(),
                    style: const TextStyle(
                      color: Color(0xFF2B308B),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                const Text(
                  'New version is ready',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),

                // Description — the backend's own message for this update.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13.5,
                      height: 1.5,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Download & Install Button — swaps to a progress state
                // while the APK downloads, and shows an inline error (with
                // the same button acting as Retry) if it fails.
                Obx(() {
                  final bool isDownloading = controller.isDownloading.value;
                  final double progress = controller.progress.value;
                  final String? error = controller.error.value;

                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isDownloading ? null : () => controller.downloadAndInstall(updateUrl),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B308B),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: const Color(0xFF2B308B).withValues(alpha: 0.6),
                            elevation: 6,
                            shadowColor: const Color(0xFF2B308B).withValues(alpha: 0.4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: isDownloading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.white),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      'Downloading ${(progress * 100).round()}%',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Download & Install',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 16,
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12.5, color: Colors.redAccent, height: 1.4),
                        ),
                      ],
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
