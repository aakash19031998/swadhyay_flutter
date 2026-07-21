import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_dimensions.dart';

/// Lets a parent (typically a GetX controller) imperatively clear the PIN
/// boxes — e.g. after a failed sign-in attempt — without the widget
/// exposing its internal `State`.
class AppPinFieldController {
  _AppPinFieldState? _state;

  void _attach(_AppPinFieldState state) => _state = state;

  void _detach(_AppPinFieldState state) {
    if (_state == state) _state = null;
  }

  void clear() => _state?._clear();

  String get text => _state?._currentPin ?? '';
}

/// Segmented PIN input: [length] separate boxes with auto-advance focus,
/// backspace-to-previous, numeric keyboard, obscured digits, and paste
/// support (pasting a full code into any box distributes it across boxes).
class AppPinField extends StatefulWidget {
  const AppPinField({
    super.key,
    this.length = AppDimensions.pinLength,
    this.obscureText = true,
    this.autofocus = false,
    this.controller,
    this.onChanged,
    this.onCompleted,
    this.errorText,
  });

  final int length;
  final bool obscureText;
  final bool autofocus;
  final AppPinFieldController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final String? errorText;

  @override
  State<AppPinField> createState() => _AppPinFieldState();
}

class _AppPinFieldState extends State<AppPinField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  String get _currentPin => _controllers.map((c) => c.text).join();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
    widget.controller?._attach(this);
  }

  @override
  void dispose() {
    widget.controller?._detach(this);
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _clear() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    widget.onChanged?.call('');
    setState(() {});
  }

  void _handleChanged(int index, String value) {
    if (value.length > 1) {
      _distributePaste(index, value);
      return;
    }

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == widget.length - 1) {
      _focusNodes[index].unfocus();
    }

    _notify();
  }

  void _distributePaste(int startIndex, String pasted) {
    final String digits = pasted.replaceAll(RegExp(r'\D'), '');
    int cursor = startIndex;
    for (final rune in digits.split('')) {
      if (cursor >= widget.length) break;
      _controllers[cursor].text = rune;
      cursor++;
    }
    final int lastFilled = (cursor - 1).clamp(0, widget.length - 1);
    if (cursor >= widget.length) {
      _focusNodes[lastFilled].unfocus();
    } else {
      _focusNodes[cursor].requestFocus();
    }
    setState(() {});
    _notify();
  }

  void _handleBackspace(int index) {
    if (_controllers[index].text.isEmpty && index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      _notify();
    }
  }

  void _notify() {
    final String pin = _currentPin;
    widget.onChanged?.call(pin);
    if (pin.length == widget.length) {
      widget.onCompleted?.call(pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colors = Theme.of(context).colorScheme;
    final bool hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index == widget.length - 1 ? 0 : AppDimensions.pinBoxSpacing,
              ),
              child: SizedBox(
                width: AppDimensions.pinBoxSize,
                height: AppDimensions.pinBoxSize,
                child: Focus(
                  onKeyEvent: (node, event) {
                    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
                      _handleBackspace(index);
                    }
                    return KeyEventResult.ignored;
                  },
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    autofocus: widget.autofocus && index == 0,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    obscureText: widget.obscureText,
                    obscuringCharacter: '●',
                    maxLength: widget.length,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: Theme.of(context).textTheme.headlineSmall,
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        borderSide: BorderSide(color: hasError ? colors.error : colors.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        borderSide: BorderSide(color: hasError ? colors.error : colors.outlineVariant),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                        borderSide: BorderSide(color: hasError ? colors.error : colors.primary, width: 1.5),
                      ),
                    ),
                    onChanged: (value) => _handleChanged(index, value),
                  ),
                ),
              ),
            );
          }),
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            widget.errorText!,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.error),
          ),
        ],
      ],
    );
  }
}
