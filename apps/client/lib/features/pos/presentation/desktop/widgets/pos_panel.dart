import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:flutter/material.dart';

/// Shared bordered surface used for POS panels.
class PosPanel extends StatelessWidget {
  const PosPanel({
    required this.child,
    this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  static const Color borderColor = posCardBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: posCardBorder),
        borderRadius: AppRadius.mdBorder,
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}

/// Responsive breakpoints for the POS screen.
abstract final class PosBreakpoints {
  static const desktop = 1200.0;
  static const laptop = 960.0;
  static const tablet = 720.0;
  static const mobile = 600.0;
}
