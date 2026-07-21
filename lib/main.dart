import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/constants/app_strings.dart';
import 'core/di/initial_binding.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    );
  }
}
