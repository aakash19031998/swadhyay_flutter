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
    this.controller,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final Duration debounce;

  /// Optional external controller — e.g. so the Bag List's scan button can
  /// show a scanned value in this same field instead of only filtering
  /// silently. When omitted (every other caller), an internal controller is
  /// used exactly as before.
  final TextEditingController? controller;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _debounceTimer;
  late final TextEditingController _controller = widget.controller ?? TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.removeListener(_handleTextChanged);
    if (widget.controller == null) _controller.dispose();
    super.dispose();
  }

  // Only drives the clear (X) button's visibility — the debounced fetch
  // itself still runs through _handleChanged below.
  void _handleTextChanged() => setState(() {});

  void _handleChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () => widget.onChanged(value));
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _handleChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: widget.hint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
        contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
      ),
    );
  }
}
