import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/material.dart';

class MasterDetailSplitLayout extends StatelessWidget {
  const MasterDetailSplitLayout({
    required this.listPanel,
    required this.detailPanel,
    this.listWidth = 360,
    super.key,
  });

  final Widget listPanel;
  final Widget detailPanel;
  final double listWidth;

  static const _compactBreakpoint = 800.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < _compactBreakpoint;
        final resolvedListWidth = isCompact
            ? constraints.maxWidth
            : listWidth.clamp(280.0, constraints.maxWidth * 0.42);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadius.lgBorder,
            border: Border.all(color: listPanelCardBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: AppRadius.lgBorder,
            child: isCompact
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Flexible(
                        flex: 2,
                        child: listPanel,
                      ),
                      const Divider(
                        height: 1,
                        color: listPanelCardBorder,
                      ),
                      Flexible(
                        flex: 3,
                        child: detailPanel,
                      ),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(width: resolvedListWidth, child: listPanel),
                      const VerticalDivider(
                        width: 1,
                        color: listPanelCardBorder,
                      ),
                      Expanded(child: detailPanel),
                    ],
                  ),
          ),
        );
      },
    );
  }
}

class MasterDetailPlaceholder extends StatelessWidget {
  const MasterDetailPlaceholder({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: ListPanelStyles.emptyStateStyle),
    );
  }
}
