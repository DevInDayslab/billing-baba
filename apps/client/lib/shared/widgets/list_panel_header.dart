import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:flutter/material.dart';

class ListPanelHeader extends StatelessWidget {
  const ListPanelHeader({required this.columns, super.key});

  final List<ListPanelColumn> columns;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: listPanelCardBorder)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < columns.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(
              flex: columns[i].flex,
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      columns[i].label,
                      style: ListPanelStyles.listHeaderStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                  if (columns[i].showFilter) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.filter_list,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(width: 28),
        ],
      ),
    );
  }
}

class ListPanelColumn {
  const ListPanelColumn({
    required this.label,
    this.flex = 1,
    this.showFilter = false,
  });

  final String label;
  final int flex;
  final bool showFilter;
}

class ListPanelEmptyState extends StatelessWidget {
  const ListPanelEmptyState({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text(message, style: ListPanelStyles.emptyStateStyle),
      ),
    );
  }
}
