import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _addCtaOrange = Color(0xFFFF9800);

/// Illustration + description + CTA inside a white card for sale sub-pages.
class SaleEmptyStateCard extends StatelessWidget {
  const SaleEmptyStateCard({
    required this.illustration,
    required this.description,
    required this.buttonLabel,
    this.title,
    this.onPressed,
    this.buttonColor = _addCtaOrange,
    this.buttonIcon,
    super.key,
  });

  final Widget illustration;
  final String? title;
  final String description;
  final String buttonLabel;
  final VoidCallback? onPressed;
  final Color buttonColor;
  final IconData? buttonIcon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: _cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : 480.0;

          return SizedBox(
            height: height,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: height),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      illustration,
                      if (title != null) ...[
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          title!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (buttonIcon != null)
                        FilledButton.icon(
                          onPressed: onPressed ?? () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          icon: Icon(buttonIcon, size: 18),
                          label: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      else
                        FilledButton(
                          onPressed: onPressed ?? () {},
                          style: FilledButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 14,
                            ),
                            shape: const StadiumBorder(),
                          ),
                          child: Text(
                            buttonLabel,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Simple geometric illustration used across sale empty states.
class SaleGeometricIllustration extends StatelessWidget {
  const SaleGeometricIllustration({
    required this.circleColor,
    required this.shapeColor,
    this.shapeIcon,
    super.key,
  });

  final Color circleColor;
  final Color shapeColor;
  final IconData? shapeIcon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 230,
      height: 230,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 230,
            height: 230,
            decoration: BoxDecoration(
              color: circleColor,
              shape: BoxShape.circle,
            ),
          ),
          if (shapeIcon != null)
            Icon(shapeIcon, size: 72, color: shapeColor)
          else
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: shapeColor,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
        ],
      ),
    );
  }
}
