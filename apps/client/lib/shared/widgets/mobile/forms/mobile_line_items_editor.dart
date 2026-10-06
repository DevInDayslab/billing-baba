import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Simple line list for mobile document forms.
class MobileLineItemsEditor extends StatelessWidget {
  const MobileLineItemsEditor({
    required this.lines,
    required this.onAdd,
    required this.onRemove,
    super.key,
    this.title = 'Line items',
    this.emptyMessage = 'No items added yet.',
  });

  final List<MobileLineItemDisplay> lines;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final String title;
  final String emptyMessage;

  static final _currency = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: AppTypography.inter(
                  fontSize: AppTypography.subtitleSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add'),
            ),
          ],
        ),
        if (lines.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Text(
              emptyMessage,
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                color: AppColors.textSecondary,
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: lines.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final line = lines[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  title: Text(line.title),
                  subtitle: Text(
                    '${line.quantity} × ${_currency.format(line.unitPrice)}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _currency.format(line.total),
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.trash2),
                        onPressed: () => onRemove(index),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class MobileLineItemDisplay {
  const MobileLineItemDisplay({
    required this.title,
    required this.quantity,
    required this.unitPrice,
    required this.total,
  });

  final String title;
  final double quantity;
  final double unitPrice;
  final double total;
}
