import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Opens a number-pad sheet to enter a cart quantity quickly.
///
/// Returns the chosen quantity, or null if cancelled.
Future<int?> showPosQuantityPad(
  BuildContext context, {
  required String itemName,
  required int initialQuantity,
  int? maxQuantity,
}) {
  return showMobileBottomSheet<int>(
    context: context,
    title: 'Quantity',
    heightFraction: 0.62,
    scrollBody: false,
    builder: (sheetContext) => _PosQuantityPadBody(
      itemName: itemName,
      initialQuantity: initialQuantity,
      maxQuantity: maxQuantity,
    ),
  );
}

class _PosQuantityPadBody extends StatefulWidget {
  const _PosQuantityPadBody({
    required this.itemName,
    required this.initialQuantity,
    this.maxQuantity,
  });

  final String itemName;
  final int initialQuantity;
  final int? maxQuantity;

  @override
  State<_PosQuantityPadBody> createState() => _PosQuantityPadBodyState();
}

class _PosQuantityPadBodyState extends State<_PosQuantityPadBody> {
  late String _value;
  var _replaceOnNextDigit = true;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialQuantity > 0 ? widget.initialQuantity : 1;
    _value = '$initial';
  }

  int get _parsed => int.tryParse(_value) ?? 0;

  void _appendDigit(String digit) {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      if (_replaceOnNextDigit) {
        _value = digit == '0' ? '0' : digit;
        _replaceOnNextDigit = false;
        return;
      }
      if (_value == '0') {
        _value = digit;
        return;
      }
      if (_value.length >= 6) return;
      _value = '$_value$digit';
    });
  }

  void _backspace() {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      if (_replaceOnNextDigit || _value.length <= 1) {
        _value = '0';
        _replaceOnNextDigit = true;
        return;
      }
      _value = _value.substring(0, _value.length - 1);
    });
  }

  void _clear() {
    unawaited(HapticFeedback.selectionClick());
    setState(() {
      _value = '0';
      _replaceOnNextDigit = true;
    });
  }

  void _apply() {
    var qty = _parsed;
    final max = widget.maxQuantity;
    if (max != null && max >= 0 && qty > max) {
      qty = max;
    }
    Navigator.of(context).pop(qty);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final max = widget.maxQuantity;
    final overMax = max != null && max >= 0 && _parsed > max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.itemName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: AppRadius.mdBorder,
            border: Border.all(
              color: overMax ? AppColors.error : const Color(0xFFE0E0E0),
            ),
          ),
          child: Text(
            _value,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: overMax ? AppColors.error : AppColors.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (max != null && max >= 0) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            overMax ? 'Max available stock: $max' : 'Stock available: $max',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: overMax ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        Expanded(
          child: _NumberPadGrid(
            onDigit: _appendDigit,
            onBackspace: _backspace,
            onClear: _clear,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              flex: 2,
              child: FilledButton(
                onPressed: _apply,
                child: const Text('Apply'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumberPadGrid extends StatelessWidget {
  const _NumberPadGrid({
    required this.onDigit,
    required this.onBackspace,
    required this.onClear,
  });

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['C', '0', '⌫'],
    ];

    return Column(
      children: [
        for (final row in keys)
          Expanded(
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _PadKey(
                        label: key,
                        onTap: () {
                          if (key == 'C') {
                            onClear();
                          } else if (key == '⌫') {
                            onBackspace();
                          } else {
                            onDigit(key);
                          }
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isAction = label == 'C' || label == '⌫';

    return Material(
      color: isAction
          ? AppColors.primary.withValues(alpha: 0.08)
          : AppColors.surface,
      borderRadius: AppRadius.mdBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: const Color(0xFFE0E0E0)),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: isAction ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
