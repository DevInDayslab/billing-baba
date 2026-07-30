import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _secondaryButtonBg = Color(0xFFF2F2F2);
const _iconCircleBg = Color(0xFFE8F0FE);
const _iconAccent = Color(0xFF5C9CE6);
const _iconAccentDark = Color(0xFF1565C0);
const _deleteActionRed = Color(0xFFE53935);

const saleInvoiceSkipDeleteWarningKey = 'sale_invoice_skip_delete_warning';

enum SaleInvoiceDeleteDialogResult {
  continueDeleting,
  cancelInvoice,
}

/// Whether the user opted out of the delete-invoice education dialog.
Future<bool> readSaleInvoiceSkipDeleteWarning(WidgetRef ref) async {
  final storage = await ref.read(storageServiceProvider.future);
  return storage.read(saleInvoiceSkipDeleteWarningKey) == 'true';
}

Future<void> writeSaleInvoiceSkipDeleteWarning(WidgetRef ref) async {
  final storage = await ref.read(storageServiceProvider.future);
  await storage.write(saleInvoiceSkipDeleteWarningKey, 'true');
}

/// Shows the delete-invoice education modal.
Future<SaleInvoiceDeleteDialogResult?> showSaleInvoiceDeleteDialog(
  BuildContext context,
) {
  return showDialog<SaleInvoiceDeleteDialogResult>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x99000000),
    builder: (context) => const Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: SaleInvoiceDeleteDialog(),
    ),
  );
}

class SaleInvoiceDeleteDialog extends ConsumerStatefulWidget {
  const SaleInvoiceDeleteDialog({super.key});

  @override
  ConsumerState<SaleInvoiceDeleteDialog> createState() =>
      _SaleInvoiceDeleteDialogState();
}

class _SaleInvoiceDeleteDialogState
    extends ConsumerState<SaleInvoiceDeleteDialog> {
  bool _dontShowAgain = false;

  Future<void> _popWithResult(SaleInvoiceDeleteDialogResult result) async {
    if (_dontShowAgain) {
      await writeSaleInvoiceSkipDeleteWarning(ref);
    }
    if (!mounted) return;
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(color: _cardBorder),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.lgBorder,
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl + AppSpacing.sm,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: _DeleteInvoiceIllustration()),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Deleting the invoice will delete all records of this '
                      'invoice.',
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'You can also CANCEL the invoice, which will preserve '
                      'the cancelled copy and serial number of the invoice.',
                      textAlign: TextAlign.center,
                      style: AppTypography.inter(
                        fontSize: 13,
                        height: 1.55,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    InkWell(
                      onTap: () => setState(
                        () => _dontShowAgain = !_dontShowAgain,
                      ),
                      borderRadius: AppRadius.smBorder,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _dontShowAgain,
                                onChanged: (value) => setState(
                                  () => _dontShowAgain = value ?? false,
                                ),
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                side: const BorderSide(
                                  color: Color(0xFFBDBDBD),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(
                              "Don't show this message again!",
                              style: AppTypography.inter(
                                fontSize: 13,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _DialogActionButton(
                          label: 'Continue Deleting',
                          backgroundColor: _secondaryButtonBg,
                          foregroundColor: AppColors.textPrimary,
                          onPressed: () => _popWithResult(
                            SaleInvoiceDeleteDialogResult.continueDeleting,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        _DialogActionButton(
                          label: 'Cancel Invoice',
                          backgroundColor: _deleteActionRed,
                          foregroundColor: Colors.white,
                          onPressed: () => _popWithResult(
                            SaleInvoiceDeleteDialogResult.cancelInvoice,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.close,
                    size: 20,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: 'Close',
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteInvoiceIllustration extends StatelessWidget {
  const _DeleteInvoiceIllustration();

  static const _dotColor = Color(0xFFB3D4F5);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      height: 108,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          const _DecorativeDot(left: 6, top: 28, size: 6),
          const _DecorativeDot(right: 4, top: 18, size: 5),
          const _DecorativeDot(left: 18, bottom: 10, size: 4),
          const _DecorativeDot(right: 16, bottom: 14, size: 6),
          const _DecorativeDot(left: 42, top: 2, size: 4),
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: _iconCircleBg,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(
            width: 44,
            height: 48,
            child: Stack(
              alignment: Alignment.bottomCenter,
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  left: 4,
                  child: Transform.rotate(
                    angle: -0.18,
                    child: Container(
                      width: 14,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: _iconAccent, width: 1.2),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Transform.rotate(
                    angle: 0.22,
                    child: Container(
                      width: 12,
                      height: 16,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD6E8FA),
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(color: _iconAccent, width: 1.2),
                      ),
                    ),
                  ),
                ),
                Container(
                  width: 40,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(6),
                    ),
                    border: Border.all(color: _iconAccent, width: 1.5),
                  ),
                ),
                Positioned(
                  top: 10,
                  child: Container(
                    width: 44,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _iconAccentDark,
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(color: _iconAccentDark),
                    ),
                  ),
                ),
                ...List.generate(3, (index) {
                  return Positioned(
                    bottom: 8,
                    left: 10 + (index * 8.0),
                    child: Container(
                      width: 2,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _iconAccent.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeDot extends StatelessWidget {
  const _DecorativeDot({
    required this.size,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  final double? left;
  final double? right;
  final double? top;
  final double? bottom;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: _DeleteInvoiceIllustration._dotColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _DialogActionButton extends StatelessWidget {
  const _DialogActionButton({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.onPressed,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: AppTypography.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
