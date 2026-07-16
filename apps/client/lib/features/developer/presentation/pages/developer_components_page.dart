import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/dashboard/presentation/pages/coming_soon_page.dart';
import 'package:billing_baba/features/developer/models/developer_sub_route.dart';
import 'package:billing_baba/features/developer/presentation/pages/table_filters_playground_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Developer > Components index — bento catalog for reusable UI.
class DeveloperComponentsPage extends StatelessWidget {
  const DeveloperComponentsPage({super.key});

  static const _borderColor = Color(0xFFE0E0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = _columnCount(constraints.maxWidth);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Components',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'Reusable UI building blocks for Billing Baba.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                sliver: SliverToBoxAdapter(
                  child: _BentoGrid(
                    items: DeveloperSubRoutes.items,
                    columns: columns,
                    onTap: (item) => context.go(item.route),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  static int _columnCount(double width) {
    if (width >= 1100) return 4;
    if (width >= 720) return 3;
    return 2;
  }
}

class _BentoGrid extends StatelessWidget {
  const _BentoGrid({
    required this.items,
    required this.columns,
    required this.onTap,
  });

  final List<DeveloperSubRoute> items;
  final int columns;
  final ValueChanged<DeveloperSubRoute> onTap;

  static const double _gap = AppSpacing.md;
  static const double _rowHeight = 148;
  static const double _heroHeight = 316;

  @override
  Widget build(BuildContext context) {
    final rows = _packRows(items, columns);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth =
            (constraints.maxWidth - _gap * (columns - 1)) / columns;

        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0) const SizedBox(height: _gap),
              SizedBox(
                height: rows[i].height,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var j = 0; j < rows[i].cells.length; j++) ...[
                      if (j > 0) const SizedBox(width: _gap),
                      SizedBox(
                        width:
                            cellWidth * rows[i].cells[j].span +
                            _gap * (rows[i].cells[j].span - 1),
                        child: _BentoTile(
                          item: rows[i].cells[j].item,
                          onTap: () => onTap(rows[i].cells[j].item),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  static List<_BentoRow> _packRows(List<DeveloperSubRoute> items, int columns) {
    final rows = <_BentoRow>[];
    var index = 0;

    while (index < items.length) {
      final cells = <_BentoCell>[];
      var used = 0;
      var rowHeight = _rowHeight;

      while (index < items.length && used < columns) {
        final item = items[index];
        final span = item.size == DeveloperBentoSize.hero
            ? (columns >= 3 ? 2 : 1)
            : 1;

        if (used + span > columns) break;

        cells.add(_BentoCell(item: item, span: span));
        used += span;
        if (item.size == DeveloperBentoSize.hero) {
          rowHeight = _heroHeight;
        }
        index++;
      }

      rows.add(
        _BentoRow(
          cells: cells,
          height: rowHeight,
        ),
      );
    }

    return rows;
  }
}

class _BentoRow {
  const _BentoRow({
    required this.cells,
    required this.height,
  });

  final List<_BentoCell> cells;
  final double height;
}

class _BentoCell {
  const _BentoCell({
    required this.item,
    required this.span,
  });

  final DeveloperSubRoute item;
  final int span;
}

class _BentoTile extends StatefulWidget {
  const _BentoTile({
    required this.item,
    required this.onTap,
  });

  final DeveloperSubRoute item;
  final VoidCallback onTap;

  @override
  State<_BentoTile> createState() => _BentoTileState();
}

class _BentoTileState extends State<_BentoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isHero = item.size == DeveloperBentoSize.hero;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: _hovered
              ? AppColors.primary.withValues(alpha: 0.04)
              : AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: _hovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : DeveloperComponentsPage._borderColor,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.08 : 0.04),
              blurRadius: _hovered ? 16 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: AppRadius.lgBorder,
            child: Padding(
              padding: EdgeInsets.all(isHero ? AppSpacing.lg : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: isHero ? 48 : 40,
                        height: isHero ? 48 : 40,
                        decoration: BoxDecoration(
                          color: item.implemented
                              ? AppColors.primary.withValues(alpha: 0.1)
                              : AppColors.background,
                          borderRadius: AppRadius.mdBorder,
                        ),
                        child: Icon(
                          item.icon,
                          size: isHero ? 24 : 20,
                          color: item.implemented
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      _StatusChip(implemented: item.implemented),
                    ],
                  ),
                  SizedBox(height: isHero ? AppSpacing.md : AppSpacing.sm),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: isHero ? 20 : 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      item.description,
                      style: TextStyle(
                        fontSize: isHero ? 14 : 12,
                        height: 1.35,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: isHero ? 4 : 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isHero && item.implemented) ...[
                    const SizedBox(height: AppSpacing.sm),
                    const Row(
                      children: [
                        Text(
                          'Open playground',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.implemented});

  final bool implemented;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: implemented
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        implemented ? 'Ready' : 'Soon',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: implemented ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

/// Placeholder for unimplemented component catalog pages.
class DeveloperComponentPlaceholderPage extends StatelessWidget {
  const DeveloperComponentPlaceholderPage({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return ComingSoonPage(title: title);
  }
}

/// Routes table-filter playground when selected from the components index.
Widget buildDeveloperComponentPage(String route) {
  if (route == AppRoutes.developerComponentsTableFilters) {
    return const TableFiltersPlaygroundPage();
  }

  return DeveloperComponentPlaceholderPage(
    title: DeveloperSubRoutes.labelForRoute(route),
  );
}
