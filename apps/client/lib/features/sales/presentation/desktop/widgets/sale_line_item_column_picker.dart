import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/models/item_settings.dart';
import 'package:billing_baba/features/sales/models/sale_line_item_columns.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_line_items_table_layout.dart';
import 'package:flutter/material.dart';

const _menuWidth = 220.0;
const _checkboxSize = 18.0;

/// Blue "+" trigger that opens a checkbox menu to show/hide line-item columns.
class SaleLineItemColumnPickerButton extends StatelessWidget {
  const SaleLineItemColumnPickerButton({
    required this.visibility,
    required this.onToggle,
    this.onMoreSettings,
    this.itemSettings,
    super.key,
  });

  final SaleLineItemColumnVisibility visibility;
  final ValueChanged<SaleLineItemColumn> onToggle;
  final VoidCallback? onMoreSettings;
  final ItemSettings? itemSettings;

  bool _isColumnOffered(SaleLineItemColumn column) {
    final settings = itemSettings;
    if (settings == null) return true;
    return switch (column) {
      SaleLineItemColumn.taxPercent || SaleLineItemColumn.taxAmount =>
        settings.itemWiseTax,
      SaleLineItemColumn.discount => settings.itemWiseDiscount,
      _ => true,
    };
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        padding: const WidgetStatePropertyAll(EdgeInsets.zero),
        elevation: const WidgetStatePropertyAll(6),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        backgroundColor: const WidgetStatePropertyAll(Colors.white),
      ),
      alignmentOffset: const Offset(-_menuWidth + 28, 0),
      menuChildren: [
        SizedBox(
          width: _menuWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final column in SaleLineItemColumn.values)
                if (_isColumnOffered(column))
                  _ColumnToggleTile(
                    label: column.label,
                    value: visibility.isVisible(column),
                    onChanged: (_) => onToggle(column),
                  ),
              if (onMoreSettings != null) ...[
                const Divider(
                  height: 1,
                  color: SaleLineItemTableLayout.gridBorderColor,
                ),
                InkWell(
                  onTap: onMoreSettings,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.settings_outlined,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'More Settings',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
      builder: (context, controller, child) {
        return Material(
          color: AppColors.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              if (controller.isOpen) {
                controller.close();
              } else {
                controller.open();
              }
            },
            child: const SizedBox(
              width: 22,
              height: 22,
              child: Icon(Icons.add, size: 16, color: Colors.white),
            ),
          ),
        );
      },
    );
  }
}

class _ColumnToggleTile extends StatelessWidget {
  const _ColumnToggleTile({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          children: [
            SizedBox(
              width: _checkboxSize,
              height: _checkboxSize,
              child: Checkbox(
                value: value,
                onChanged: (checked) {
                  if (checked != null) onChanged(checked);
                },
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                side: const BorderSide(color: Color(0xFFBDBDBD)),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Renders a grid cell only when its column is visible.
class SaleLineItemOptionalCell extends StatelessWidget {
  const SaleLineItemOptionalCell({
    required this.column,
    required this.visibility,
    required this.width,
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding = const EdgeInsets.symmetric(horizontal: 4),
    super.key,
  });

  final SaleLineItemColumn column;
  final SaleLineItemColumnVisibility visibility;
  final double width;
  final Widget child;
  final Alignment alignment;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    if (!visibility.isVisible(column) || width <= 0) {
      return const SizedBox.shrink();
    }

    return SaleLineItemGridCell(
      width: width,
      alignment: alignment,
      padding: padding,
      child: child,
    );
  }
}

/// Renders a header cell only when its column is visible.
class SaleLineItemOptionalHeaderCell extends StatelessWidget {
  const SaleLineItemOptionalHeaderCell({
    required this.column,
    required this.visibility,
    required this.width,
    required this.label,
    this.alignRight = false,
    super.key,
  });

  final SaleLineItemColumn column;
  final SaleLineItemColumnVisibility visibility;
  final double width;
  final String label;
  final bool alignRight;

  @override
  Widget build(BuildContext context) {
    if (!visibility.isVisible(column) || width <= 0) {
      return const SizedBox.shrink();
    }

    return SaleLineItemGridHeaderCell(
      label: label,
      width: width,
      alignRight: alignRight,
    );
  }
}
