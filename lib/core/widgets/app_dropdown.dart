import 'package:flutter/material.dart';

/// Generic outlined dropdown matching [AppTextField] styling.
class AppDropdown<T> extends StatelessWidget {
  const AppDropdown({
    required this.label,
    required this.items,
    required this.itemLabel,
    super.key,
    this.value,
    this.onChanged,
    this.validator,
    this.hint,
    this.icon,
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hint;

  /// Optional leading icon (e.g. distinguishing "Work Type" from "Work" at
  /// a glance) — omitted entirely when null, so every existing call site is
  /// unaffected.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: icon == null ? null : Icon(icon),
      ),
      items: items
          .map((item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))))
          .toList(growable: false),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
