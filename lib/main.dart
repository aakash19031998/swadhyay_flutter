import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'core/config/app_version.dart';
import 'core/constants/app_strings.dart';
import 'core/di/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';

/// Matches [AppTheme]'s `appBarTheme.systemOverlayStyle` — kept as one
/// literal so both agree on exactly the same status bar color. AppBarTheme
/// alone only covers screens that have an AppBar; every screen without one
/// (custom headers, gradient scaffolds, etc.) falls through to whatever the
/// previously-visited screen last set, which is why this is applied as a
/// blanket [AnnotatedRegion] below, wrapping every route.
const SystemUiOverlayStyle _statusBarStyle = SystemUiOverlayStyle(
  statusBarColor: AppColors.primary,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Locks the app to landscape (either orientation) even with the device's
  // auto-rotate on — portrait is never an allowed orientation, not just the
  // one the app happens to launch in. 1`0
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  await AppVersion.init();
  await LocalStorageService.init();
  runApp(const SwadhyayApp());
}

class SwadhyayApp extends StatelessWidget {
  const SwadhyayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialBinding: InitialBinding(),
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      // Tapping anywhere outside the focused field (any screen, not just
      // one) dismisses the keyboard. `opaque` is required — otherwise this
      // GestureDetector only catches taps on already-painted content, not
      // blank space, which is exactly where a user taps to dismiss.
      builder: (context, child) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _statusBarStyle,
          child: GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            behavior: HitTestBehavior.opaque,
            child: child,
          ),
        );
      },
    );
  }
}
