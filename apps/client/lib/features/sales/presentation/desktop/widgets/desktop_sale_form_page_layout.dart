import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Border color for sale-style transaction form cards on desktop.
const desktopSaleFormCardBorder = Color(0xFFE0E0E0);

/// Desktop shell matching [DesktopAddSalePage]: optional top chrome (e.g. tabs),
/// card filling the viewport, scrollable body, and optional pinned footer bar.
class DesktopSaleFormPageLayout extends StatelessWidget {
  const DesktopSaleFormPageLayout({
    required this.body,
    this.topBar,
    this.pinnedFooter,
    super.key,
  });

  final Widget? topBar;
  final Widget body;
  final Widget? pinnedFooter;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (topBar != null) topBar!,
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.lgBorder,
                  border: Border.all(color: desktopSaleFormCardBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0A000000),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: body,
                      ),
                    ),
                    if (pinnedFooter != null) ...[
                      const Divider(
                        height: 1,
                        color: desktopSaleFormCardBorder,
                      ),
                      pinnedFooter!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
