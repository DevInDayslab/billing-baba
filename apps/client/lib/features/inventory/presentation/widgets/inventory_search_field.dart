import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';

class InventorySearchField extends StatelessWidget {
  const InventorySearchField({
    required this.hint,
    required this.onChanged,
    this.showSettings = false,
    this.onSettingsTap,
    super.key,
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final bool showSettings;
  final VoidCallback? onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: saleFieldTextStyle,
      decoration: buildSaleFieldDecoration(
        hint: hint,
        suffixIcon: showSettings
            ? IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings_outlined, size: 18),
                color: Colors.grey.shade600,
                tooltip: 'Settings',
              )
            : const Icon(Icons.search, size: 18, color: Colors.grey),
      ),
    );
  }
}
