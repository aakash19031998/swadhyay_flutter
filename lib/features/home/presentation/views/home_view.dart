import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/widgets/common_app_bar.dart';
import '../controllers/home_controller.dart';
import '../widgets/app_drawer.dart';
import '../widgets/dashboard_body.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CommonAppBar(showNotification: false),
      drawer: const AppDrawer(),
      // Fires every time the drawer is opened (hamburger tap or swipe) —
      // re-fetches the menu fresh each time instead of showing whatever
      // was last loaded.
      onDrawerChanged: (isOpened) {
        if (isOpened) controller.loadMenu();
      },
      body: const DashboardBody(),
    );
  }
}
