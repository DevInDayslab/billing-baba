import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/utils/validators.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef AdditionalPhoneFieldBuilder =
    Widget Function({
      required TextEditingController controller,
      required String? errorText,
      required VoidCallback onRemove,
      required VoidCallback onChanged,
    });

class PartyAdditionalPhonesField extends StatelessWidget {
  const PartyAdditionalPhonesField({
    required this.controllers,
    required this.errors,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
    required this.fieldBuilder,
    super.key,
  });

  final List<TextEditingController> controllers;
  final List<String?> errors;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index) onChanged;
  final AdditionalPhoneFieldBuilder fieldBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < controllers.length; index++) ...[
          if (index > 0) const SizedBox(height: 8),
          fieldBuilder(
            controller: controllers[index],
            errorText: errors[index],
            onRemove: () => onRemove(index),
            onChanged: () => onChanged(index),
          ),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Add another number'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

Widget buildAdditionalPhoneInput({
  required TextEditingController controller,
  required String? errorText,
  required VoidCallback onRemove,
  required VoidCallback onChanged,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              maxLength: 10,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: saleFieldTextStyle,
              decoration: buildSaleFieldDecoration(
                hint: 'Additional Mobile',
                hasError: errorText != null,
              ),
              onChanged: (_) => onChanged(),
            ),
            if (errorText != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  errorText,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
      IconButton(
        onPressed: onRemove,
        icon: const Icon(Icons.close, size: 18),
        tooltip: 'Remove number',
        color: AppColors.textSecondary,
      ),
    ],
  );
}

String? validateAdditionalPhone(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter a phone number or remove this field';
  }
  return Validators.phone(value);
}
