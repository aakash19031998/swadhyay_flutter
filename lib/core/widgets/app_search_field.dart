import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';

/// Debounced search field used at the top of every list/report screen, so
/// typing doesn't trigger a fetch per keystroke.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.onChanged,
    super.key,
    this.hint = AppStrings.search,
    this.debounce = const Duration(milliseconds: 400),
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final Duration debounce;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _handleChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: _handleChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
      ),
    );
  }
}
