import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shortcut shown in the items "More Options" bottom sheet.
class ItemMoreOption {
  const ItemMoreOption({
    required this.label,
    required this.icon,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.backgroundColor = const Color(0xFFE3F2FD),
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final Color backgroundColor;
}

/// Grid bottom sheet for extra item shortcuts (Show All).
Future<void> showItemMoreOptionsSheet({
  required BuildContext context,
  required List<ItemMoreOption> options,
}) {
  if (options.isEmpty) return Future.value();

  return showMobileBottomSheet<void>(
    context: context,
    maxHeightFraction: 0.45,
    titleWidget: Builder(
      builder: (sheetContext) => _MoreOptionsHeader(
        onClose: () => Navigator.of(sheetContext).pop(),
      ),
    ),
    builder: (sheetContext) {
      return _MoreOptionsGrid(
        options: options,
        onOptionTap: (option) {
          Navigator.of(sheetContext).pop();
          option.onTap();
        },
      );
    },
  );
}

class _MoreOptionsHeader extends StatelessWidget {
  const _MoreOptionsHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'More Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close_rounded),
              color: AppColors.textSecondary,
              iconSize: 22,
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            ),
          ],
        ),
        const Gap(AppSpacing.sm),
        const Divider(
          height: 1,
          color: Color(0xFFE0E0E0),
        ),
      ],
    );
  }
}

class _MoreOptionsGrid extends StatelessWidget {
  const _MoreOptionsGrid({
    required this.options,
    required this.onOptionTap,
  });

  final List<ItemMoreOption> options;
  final ValueChanged<ItemMoreOption> onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const Gap(AppSpacing.sm),
          Expanded(
            child: _MoreOptionTile(
              option: options[i],
              onTap: () => onOptionTap(options[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _MoreOptionTile extends StatelessWidget {
  const _MoreOptionTile({
    required this.option,
    required this.onTap,
  });

  final ItemMoreOption option;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: option.backgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(option.icon, color: option.iconColor, size: 26),
          ),
          const Gap(AppSpacing.sm),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
