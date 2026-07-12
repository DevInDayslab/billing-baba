import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/forms/form_spacing.dart';
import 'package:flutter/material.dart';

/// Bordered section card used by Pricing / Stock / Online / Manufacturing.
class FormSection extends StatelessWidget {
  const FormSection({
    required this.child,
    this.title,
    this.padding = const EdgeInsets.all(FormSpacing.cardPadding),
    super.key,
  });

  final Widget child;
  final String? title;
  final EdgeInsetsGeometry padding;

  static const Color borderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: borderColor),
        borderRadius: FormSpacing.cardBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: FormSpacing.row),
          ],
          child,
        ],
      ),
    );
  }
}
