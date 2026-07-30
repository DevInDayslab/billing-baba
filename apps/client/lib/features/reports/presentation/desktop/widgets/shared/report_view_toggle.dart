import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ReportViewToggle extends StatelessWidget {
  const ReportViewToggle({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'View :',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ViewOption(
          label: 'Vyapar',
          selected: value == 'Vyapar',
          onTap: () => onChanged('Vyapar'),
        ),
        const SizedBox(width: AppSpacing.sm),
        _ViewOption(
          label: 'Accounting',
          selected: value == 'Accounting',
          onTap: () => onChanged('Accounting'),
        ),
      ],
    );
  }
}

class _ViewOption extends StatelessWidget {
  const _ViewOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            size: 18,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
