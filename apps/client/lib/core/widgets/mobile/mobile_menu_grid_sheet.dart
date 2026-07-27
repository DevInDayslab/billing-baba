import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_sheet_models.dart';
import 'package:flutter/material.dart';

/// Shows a Vyapar-style icon grid bottom sheet (e.g. More Options, Add Txn).
Future<void> showMobileMenuGridSheet({
  required BuildContext context,
  required String title,
  required List<MobileMenuGridItem> items,
  int columns = 3,
  double maxHeightFraction = 0.72,
  double? heightFraction,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    maxHeightFraction: maxHeightFraction,
    heightFraction: heightFraction,
    titleWidget: _MenuGridSheetHeader(title: title),
    builder: (sheetContext) {
      return _MenuGridContent(
        items: items,
        columns: columns,
        onItemTap: (item) {
          Navigator.of(sheetContext).pop();
          item.onTap();
        },
      );
    },
  );
}

class _MenuGridSheetHeader extends StatelessWidget {
  const _MenuGridSheetHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Icon(
            Icons.close_rounded,
            color: AppColors.textSecondary.withValues(alpha: 0.7),
          ),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(width: 32, height: 32),
        ),
      ],
    );
  }
}

class _MenuGridContent extends StatelessWidget {
  const _MenuGridContent({
    required this.items,
    required this.columns,
    required this.onItemTap,
  });

  final List<MobileMenuGridItem> items;
  final int columns;
  final ValueChanged<MobileMenuGridItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<MobileMenuGridItem>>[];
    for (var i = 0; i < items.length; i += columns) {
      final end = (i + columns).clamp(0, items.length);
      rows.add(items.sublist(i, end));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          if (rowIndex > 0) const SizedBox(height: AppSpacing.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var col = 0; col < columns; col++) ...[
                if (col > 0) const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: col < rows[rowIndex].length
                      ? _MenuGridTile(
                          item: rows[rowIndex][col],
                          onTap: rows[rowIndex][col].enabled
                              ? () => onItemTap(rows[rowIndex][col])
                              : null,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _MenuGridTile extends StatelessWidget {
  const _MenuGridTile({required this.item, this.onTap});

  final MobileMenuGridItem item;
  final VoidCallback? onTap;

  static const _iconBackground = Color(0xFFE8F4FD);
  static const _iconColor = Color(0xFF1E2A3A);
  static const _premiumColor = Color(0xFF7B1FA2);

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onTap == null ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _iconBackground,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    item.icon,
                    color: item.iconColor ?? _iconColor,
                    size: 26,
                  ),
                ),
                if (item.showHighlight)
                  const Positioned(
                    top: -4,
                    right: -6,
                    child: _SparkleAccent(),
                  ),
                if (item.showPremiumBadge)
                  const Positioned(
                    top: -6,
                    right: -6,
                    child: Icon(
                      Icons.workspace_premium_rounded,
                      size: 18,
                      color: _premiumColor,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                fontSize: 11,
                height: 1.25,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparkleAccent extends StatelessWidget {
  const _SparkleAccent();

  static const _color = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 18,
      height: 14,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(left: 0, top: 4, child: Icon(Icons.star, size: 7, color: _color)),
          Positioned(left: 6, top: 0, child: Icon(Icons.star, size: 9, color: _color)),
          Positioned(left: 11, top: 5, child: Icon(Icons.star, size: 6, color: _color)),
        ],
      ),
    );
  }
}
