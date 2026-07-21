import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Standard outlined text field. Wraps [TextFormField] so label, hint,
/// validation and icon placement render identically everywhere a form field
/// is needed.
class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    super.key,
    this.controller,
    this.hint,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autovalidateMode,
    this.textInputAction,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? Function(String?)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final AutovalidateMode? autovalidateMode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      enabled: enabled,
      validator: validator,
      autovalidateMode: autovalidateMode,
      textInputAction: textInputAction,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon == null ? null : Icon(prefixIcon),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
