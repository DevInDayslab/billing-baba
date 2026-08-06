import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:flutter/material.dart';

/// Locks visible sheet height; filter list scrolls inside when needed.
const mobileTransactionTypeFilterSheetHeightFraction = 0.58;

/// Vyapar-style multi-select transaction type filter for the home feed.
Future<Set<MobileHomeTransactionFilterType>?>
showMobileTransactionTypeFilterSheet({
  required BuildContext context,
  required Set<MobileHomeTransactionFilterType> selected,
}) {
  return showMobileBottomSheet<Set<MobileHomeTransactionFilterType>>(
    context: context,
    heightFraction: mobileTransactionTypeFilterSheetHeightFraction,
    scrollBody: false,
    titleWidget: const _FilterSheetHeader(),
    builder: (sheetContext) {
      return _TransactionTypeFilterBody(
        initialSelection: selected,
        onApply: (value) => Navigator.of(sheetContext).pop(value),
      );
    },
  );
}

class _FilterSheetHeader extends StatelessWidget {
  const _FilterSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Filter By',
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
        ),
        const SizedBox(height: AppSpacing.sm),
        Divider(
          height: 1,
          thickness: 1,
          color: AppColors.textSecondary.withValues(alpha: 0.15),
        ),
      ],
    );
  }
}

class _TransactionTypeFilterBody extends StatefulWidget {
  const _TransactionTypeFilterBody({
    required this.initialSelection,
    required this.onApply,
  });

  final Set<MobileHomeTransactionFilterType> initialSelection;
  final ValueChanged<Set<MobileHomeTransactionFilterType>> onApply;

  @override
  State<_TransactionTypeFilterBody> createState() =>
      _TransactionTypeFilterBodyState();
}

class _TransactionTypeFilterBodyState
    extends State<_TransactionTypeFilterBody> {
  static const _applyColor = AppColors.primary;
  static const _clearBackground = AppColors.chipBackground;

  late Set<MobileHomeTransactionFilterType> _selection;

  @override
  void initState() {
    super.initState();
    _selection = Set<MobileHomeTransactionFilterType>.from(
      widget.initialSelection,
    );
  }

  void _toggle(MobileHomeTransactionFilterType type) {
    setState(() {
      if (_selection.contains(type)) {
        _selection.remove(type);
      } else {
        _selection.add(type);
      }
    });
  }

  void _clear() {
    setState(_selection.clear);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: MobileHomeTransactionFilterType.values.length,
            separatorBuilder: (_, _) => Divider(
              height: 1,
              thickness: 1,
              color: AppColors.textSecondary.withValues(alpha: 0.12),
            ),
            itemBuilder: (context, index) {
              final type = MobileHomeTransactionFilterType.values[index];
              final isSelected = _selection.contains(type);
              return InkWell(
                onTap: () => _toggle(type),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          type.label,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                      _FilterCheckbox(
                        value: isSelected,
                        onChanged: (_) => _toggle(type),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _clear,
                style: OutlinedButton.styleFrom(
                  backgroundColor: _clearBackground,
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide.none,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: FilledButton(
                onPressed: () => widget.onApply(Set.unmodifiable(_selection)),
                style: FilledButton.styleFrom(
                  backgroundColor: _applyColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterCheckbox extends StatelessWidget {
  const _FilterCheckbox({
    required this.value,
    required this.onChanged,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;

  static const _activeColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(
          color: AppColors.textSecondary.withValues(alpha: 0.45),
          width: 1.5,
        ),
        activeColor: _activeColor,
        checkColor: Colors.white,
      ),
    );
  }
}
