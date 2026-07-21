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
    return const Scaffold(
      appBar: CommonAppBar(),
      drawer: AppDrawer(),
      body: DashboardBody(),
    );
  }
}
