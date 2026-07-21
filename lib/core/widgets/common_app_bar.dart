import 'package:flutter/material.dart';

import '../constants/app_strings.dart';

/// Shared app bar used by every top-level screen. The leading hamburger is
/// supplied automatically by [Scaffold] whenever a `drawer` is set — this
/// widget only needs to declare the title and trailing actions.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    this.title = AppStrings.appName,
    this.actions,
    this.onNotificationTap,
    this.showNotification = true,
  });

  final String title;
  final List<Widget>? actions;
  final VoidCallback? onNotificationTap;
  final bool showNotification;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        if (showNotification)
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Notifications',
            onPressed: onNotificationTap,
          ),
        ...?actions,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
