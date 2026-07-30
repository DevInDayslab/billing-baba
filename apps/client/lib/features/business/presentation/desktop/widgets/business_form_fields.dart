import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _fieldTextStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 14,
  fontWeight: FontWeight.w500,
);

const _dropdownItemStyle = TextStyle(
  color: AppColors.textPrimary,
  fontSize: 14,
);

class BusinessFormSectionHeader extends StatelessWidget {
  const BusinessFormSectionHeader({
    required this.title,
    required this.icon,
    super.key,
  });

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class BusinessFormField extends StatelessWidget {
  const BusinessFormField({
    required this.icon,
    required this.label,
    required this.controller,
    this.hint,
    this.validator,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.maxLines = 1,
    this.serverError,
    this.readOnly = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final String? serverError;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      style: readOnly
          ? _fieldTextStyle.copyWith(color: AppColors.textSecondary)
          : _fieldTextStyle,
      validator: (value) => serverError ?? validator?.call(value),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: businessFormFieldDecoration(
        label: label,
        hint: hint,
        icon: icon,
      ),
    );
  }
}

class BusinessFormDropdown extends StatelessWidget {
  const BusinessFormDropdown({
    required this.icon,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.validator,
    this.serverError,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;
  final String? serverError;

  @override
  Widget build(BuildContext context) {
    final effectiveItems = _effectiveItems();

    return DropdownButtonFormField<String>(
      initialValue: value,
      style: _fieldTextStyle,
      dropdownColor: Colors.white,
      iconEnabledColor: AppColors.textSecondary,
      iconDisabledColor: AppColors.textSecondary.withValues(alpha: 0.5),
      validator: (v) => serverError ?? validator?.call(v),
      decoration: businessFormFieldDecoration(
        label: label,
        icon: icon,
      ),
      items: effectiveItems
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, style: _dropdownItemStyle),
            ),
          )
          .toList(),
      selectedItemBuilder: (context) => effectiveItems
          .map(
            (item) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                item,
                style: _fieldTextStyle,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  List<String> _effectiveItems() {
    if (value == null || value!.isEmpty || items.contains(value)) {
      return items;
    }
    return [value!, ...items];
  }
}

InputDecoration businessFormFieldDecoration({
  required String label,
  required IconData icon,
  String? hint,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    errorText: errorText,
    labelStyle: const TextStyle(
      color: AppColors.textSecondary,
      fontSize: 14,
    ),
    floatingLabelStyle: const TextStyle(
      color: AppColors.primary,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
    hintStyle: TextStyle(
      color: AppColors.textSecondary.withValues(alpha: 0.75),
      fontSize: 14,
    ),
    prefixIcon: Icon(icon, size: 20, color: AppColors.textSecondary),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.md,
      vertical: AppSpacing.md,
    ),
  );
}

/// Responsive two-column form row. Stacks vertically on narrow widths.
class BusinessFormRow extends StatelessWidget {
  const BusinessFormRow({
    required this.left,
    required this.right,
    this.spacing = AppSpacing.md,
    super.key,
  });

  final Widget left;
  final Widget right;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth >= 480;
        if (!useTwoColumns) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              SizedBox(height: spacing),
              right,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            SizedBox(width: spacing),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class BusinessFormFullWidthField extends StatelessWidget {
  const BusinessFormFullWidthField({
    required this.child,
    this.spacing = AppSpacing.md,
    super.key,
  });

  final Widget child;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: spacing),
      child: child,
    );
  }
}
