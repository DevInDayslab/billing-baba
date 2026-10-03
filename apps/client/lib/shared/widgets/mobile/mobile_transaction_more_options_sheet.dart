import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:flutter/material.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Vyapar-style contextual menu for a transaction row on the mobile home feed.
Future<void> showMobileTransactionMoreOptionsSheet({
  required BuildContext context,
  VoidCallback? onDuplicate,
  VoidCallback? onShareAsPdf,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    scrollBody: false,
    titleWidget: const _MoreOptionsSheetHeader(),
    builder: (sheetContext) {
      return _MoreOptionsSheetBody(
        onDuplicate: () {
          Navigator.of(sheetContext).pop();
          onDuplicate?.call();
        },
        onShareAsPdf: () {
          Navigator.of(sheetContext).pop();
          onShareAsPdf?.call();
        },
      );
    },
  );
}

class _MoreOptionsSheetHeader extends StatelessWidget {
  const _MoreOptionsSheetHeader();

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
              onPressed: () => Navigator.of(context).pop(),
              icon: Icon(
                LucideIcons.x,
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

class _MoreOptionsSheetBody extends StatelessWidget {
  const _MoreOptionsSheetBody({
    required this.onDuplicate,
    required this.onShareAsPdf,
  });

  final VoidCallback onDuplicate;
  final VoidCallback onShareAsPdf;

  static final Color _dividerColor = AppColors.textSecondary.withValues(
    alpha: 0.15,
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MoreOptionsTile(label: 'Duplicate', onTap: onDuplicate),
        Divider(height: 1, thickness: 1, color: _dividerColor),
        _MoreOptionsTile(label: 'Share as PDF', onTap: onShareAsPdf),
      ],
    );
  }
}

class _MoreOptionsTile extends StatelessWidget {
  const _MoreOptionsTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
