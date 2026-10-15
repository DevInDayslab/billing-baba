import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TCS/TDS section + rate selector with computed tax amount preview.
class TaxWithholdingField extends StatelessWidget {
  const TaxWithholdingField({
    required this.label,
    required this.enabled,
    required this.sections,
    required this.selectedSectionId,
    required this.baseAmount,
    required this.taxAmount,
    required this.onSectionChanged,
    super.key,
  });

  final String label;
  final bool enabled;
  final List<({String id, String code, String rate})> sections;
  final String? selectedSectionId;
  final String baseAmount;
  final String taxAmount;
  final ValueChanged<String?> onSectionChanged;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<String>(
          value: selectedSectionId,
          decoration: const InputDecoration(
            labelText: 'Section',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final section in sections)
              DropdownMenuItem(
                value: section.id,
                child: Text('${section.code} (${section.rate}%)'),
              ),
          ],
          onChanged: onSectionChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: baseAmount,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Base amount',
            border: OutlineInputBorder(),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: taxAmount,
          readOnly: true,
          decoration: const InputDecoration(
            labelText: 'Tax amount',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
}
