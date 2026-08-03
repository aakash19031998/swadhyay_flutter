import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_dimensions.dart';
import '../constants/app_strings.dart';
import '../network/connectivity_checker.dart';
import '../theme/app_colors.dart';

/// Debounced search field used at the top of every list/report screen, so
/// typing doesn't trigger a fetch per keystroke. Once the debounce settles,
/// [ConnectivityChecker] is checked before [onChanged] fires — offline, the
/// shared "no internet" snackbar shows and the fetch never happens.
///
/// When [suggestionsBuilder] is provided (currently only Bag List), typing
/// also shows a tap-to-fill dropdown of matching values below the field.
/// Every other caller leaves it null and gets the exact same plain field as
/// before.
class AppSearchField extends StatefulWidget {
  const AppSearchField({
    required this.onChanged,
    super.key,
    this.hint = AppStrings.search,
    this.debounce = const Duration(milliseconds: 400),
    this.controller,
    this.suggestionsBuilder,
  });

  final ValueChanged<String> onChanged;
  final String hint;
  final Duration debounce;

  /// Optional external controller — e.g. so the Bag List's scan button can
  /// show a scanned value in this same field instead of only filtering
  /// silently. When omitted (every other caller), an internal controller is
  /// used exactly as before.
  final TextEditingController? controller;

  /// Returns the suggestion strings matching the current field text.
  /// Queried synchronously on every keystroke — it filters already-loaded
  /// in-memory data, not a fetch, so it needs no debounce of its own.
  final List<String> Function(String text)? suggestionsBuilder;

  @override
  State<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends State<AppSearchField> {
  Timer? _debounceTimer;
  late final TextEditingController _controller = widget.controller ?? TextEditingController();
  final FocusNode _focusNode = FocusNode();

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
    _focusNode.dispose();
    super.dispose();
  }

  // Only drives the clear (X) button's visibility — the debounced fetch
  // itself still runs through _handleChanged below.
  void _handleTextChanged() => setState(() {});

  void _handleChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () async {
      if (!await Get.find<ConnectivityChecker>().ensureConnected()) return;
      widget.onChanged(value);
    });
  }

  // A suggestion is an explicit choice, so it searches immediately instead
  // of waiting out the debounce.
  void _handleSuggestionSelected(String suggestion) {
    _debounceTimer?.cancel();
    widget.onChanged(suggestion);
  }

  void _clear() {
    _debounceTimer?.cancel();
    _controller.clear();
    widget.onChanged('');
  }

  InputDecoration _decoration() {
    return InputDecoration(
      hintText: widget.hint,
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _controller.text.isEmpty
          ? null
          : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
      contentPadding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingSm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> Function(String text)? suggestionsBuilder = widget.suggestionsBuilder;
    if (suggestionsBuilder == null) {
      return TextField(
        controller: _controller,
        onChanged: _handleChanged,
        textInputAction: TextInputAction.search,
        decoration: _decoration(),
      );
    }

    return RawAutocomplete<String>(
      textEditingController: _controller,
      focusNode: _focusNode,
      optionsBuilder: (TextEditingValue value) => suggestionsBuilder(value.text),
      onSelected: _handleSuggestionSelected,
      fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
        return TextField(
          controller: textEditingController,
          focusNode: focusNode,
          onChanged: _handleChanged,
          textInputAction: TextInputAction.search,
          decoration: _decoration(),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: AppDimensions.elevationMedium,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            color: AppColors.surface,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 240),
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: AppDimensions.spacingXxs),
                itemCount: options.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final String option = options.elementAt(index);
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.history, size: AppDimensions.iconSm, color: AppColors.textSecondary),
                    title: Text(option),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
