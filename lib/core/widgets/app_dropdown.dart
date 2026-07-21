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
  });

  final String label;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? Function(T?)? validator;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label, hintText: hint),
      items: items
          .map((item) => DropdownMenuItem<T>(value: item, child: Text(itemLabel(item))))
          .toList(growable: false),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
