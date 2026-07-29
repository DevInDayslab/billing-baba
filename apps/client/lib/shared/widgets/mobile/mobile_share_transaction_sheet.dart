import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_transaction_share_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

const _shareRed = Color(0xFFE53935);
const _pdfBackground = Color(0xFFE8F4FD);
const _pdfText = Color(0xFF455A64);

/// Vyapar-style share picker for a transaction row on the mobile home feed.
Future<void> showMobileShareTransactionSheet({
  required BuildContext context,
  VoidCallback? onShareAsImage,
  VoidCallback? onShareAsPdf,
}) {
  return showMobileBottomSheet<void>(
    context: context,
    scrollBody: false,
    title: 'Share transaction',
    builder: (sheetContext) {
      return _ShareTransactionSheetBody(
        onShareAsImage: () {
          Navigator.of(sheetContext).pop();
          onShareAsImage?.call();
        },
        onShareAsPdf: () {
          Navigator.of(sheetContext).pop();
          onShareAsPdf?.call();
        },
        onTransactionSettings: () {
          Navigator.of(sheetContext).pop();
          unawaited(context.push(AppRoutes.settingsTransactionMessages));
        },
      );
    },
  );
}

class _ShareTransactionSheetBody extends ConsumerStatefulWidget {
  const _ShareTransactionSheetBody({
    required this.onShareAsImage,
    required this.onShareAsPdf,
    required this.onTransactionSettings,
  });

  final VoidCallback onShareAsImage;
  final VoidCallback onShareAsPdf;
  final VoidCallback onTransactionSettings;

  @override
  ConsumerState<_ShareTransactionSheetBody> createState() =>
      _ShareTransactionSheetBodyState();
}

class _ShareTransactionSheetBodyState
    extends ConsumerState<_ShareTransactionSheetBody> {
  var _makeDefault = false;

  Future<void> _handleShare(
    MobileTransactionShareFormat format,
    VoidCallback onShare,
  ) async {
    if (_makeDefault) {
      await ref
          .read(mobileTransactionSharePreferenceProvider.notifier)
          .setDefault(format);
    }
    onShare();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _ShareFormatButton(
                label: 'Share as Image',
                backgroundColor: _shareRed,
                labelColor: Colors.white,
                onTap: () => unawaited(
                  _handleShare(
                    MobileTransactionShareFormat.image,
                    widget.onShareAsImage,
                  ),
                ),
                icon: const _ShareImageIcon(),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ShareFormatButton(
                label: 'Share as PDF',
                backgroundColor: _pdfBackground,
                labelColor: _pdfText,
                onTap: () => unawaited(
                  _handleShare(
                    MobileTransactionShareFormat.pdf,
                    widget.onShareAsPdf,
                  ),
                ),
                icon: const _SharePdfIcon(),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        InkWell(
          onTap: () => setState(() => _makeDefault = !_makeDefault),
          borderRadius: AppRadius.smBorder,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _makeDefault,
                    onChanged: (value) {
                      setState(() => _makeDefault = value ?? false);
                    },
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide(
                      color: AppColors.textSecondary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Make this as default',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: widget.onTransactionSettings,
          child: Text(
            '*To change later go to transaction settings*',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.85),
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

class _ShareFormatButton extends StatelessWidget {
  const _ShareFormatButton({
    required this.label,
    required this.backgroundColor,
    required this.labelColor,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Color backgroundColor;
  final Color labelColor;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: AppRadius.mdBorder,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              const SizedBox(height: AppSpacing.md),
              Text(
                label,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: labelColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareImageIcon extends StatelessWidget {
  const _ShareImageIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image_outlined,
        color: _shareRed,
        size: 24,
      ),
    );
  }
}

class _SharePdfIcon extends StatelessWidget {
  const _SharePdfIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        'Pdf',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: _pdfText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
