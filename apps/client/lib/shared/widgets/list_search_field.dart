import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ListSearchField extends StatelessWidget {
  const ListSearchField({
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
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        isDense: true,
        suffixIcon: showSettings
            ? IconButton(
                onPressed: onSettingsTap,
                icon: const Icon(Icons.settings_outlined, size: 18),
                color: Colors.grey.shade600,
                tooltip: 'Settings',
              )
            : Icon(Icons.search, size: 18, color: Colors.grey.shade500),
      ),
    );
  }
}
