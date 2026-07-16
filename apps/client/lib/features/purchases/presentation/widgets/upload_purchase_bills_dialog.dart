import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/purchase_document_desktop_import.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _actionRed = Color(0xFFD32F2F);
const _checkGreen = Color(0xFF2E7D32);
const _mobilePanelBg = Color(0xFFE3F2FD);
const _iconBlue = Color(0xFF1565C0);
const _iconBlueBg = Color(0xFFE3F2FD);
const _dialogMaxWidth = 760.0;

/// Opens the Upload Purchase Bills modal from the purchase bills list.
Future<void> showUploadPurchaseBillsDialog(BuildContext hostContext) {
  return showDialog<void>(
    context: hostContext,
    barrierColor: const Color(0x99000000),
    builder: (dialogContext) {
      return CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () {
            Navigator.of(dialogContext).pop();
          },
        },
        child: Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(
            horizontal: MediaQuery.sizeOf(dialogContext).width < 640
                ? AppSpacing.sm
                : AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: UploadPurchaseBillsDialog(hostContext: hostContext),
        ),
      );
    },
  );
}

/// Outlined trigger shown beside [Add Purchase] on the purchase bills list.
class UploadPurchaseBillsButton extends StatelessWidget {
  const UploadPurchaseBillsButton({super.key});

  static const _burgundy = Color(0xFF8B3A4A);
  static const _buttonHeight = 36.0;
  static const _dropdownWidth = 34.0;

  @override
  Widget build(BuildContext context) {
    void openDialog() => showUploadPurchaseBillsDialog(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        height: _buttonHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_buttonHeight / 2),
          border: Border.all(color: _burgundy),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: openDialog,
              hoverColor: _burgundy.withValues(alpha: 0.06),
              splashColor: _burgundy.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PurchaseBillScannerIcon(
                      size: 17,
                      color: _burgundy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Upload Purchase Bills',
                      style: AppTypography.inter(
                        fontSize: AppTypography.bodySmallSize,
                        fontWeight: FontWeight.w500,
                        color: _burgundy,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 1,
              height: 18,
              color: _burgundy,
            ),
            InkWell(
              onTap: openDialog,
              hoverColor: _burgundy.withValues(alpha: 0.06),
              splashColor: _burgundy.withValues(alpha: 0.1),
              child: const SizedBox(
                width: _dropdownWidth,
                height: _buttonHeight,
                child: Center(
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: _burgundy,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Viewfinder-style scanner icon used on the upload purchase bills trigger.
class _PurchaseBillScannerIcon extends StatelessWidget {
  const _PurchaseBillScannerIcon({
    required this.color,
    this.size = 18,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _PurchaseBillScannerIconPainter(color: color),
    );
  }
}

class _PurchaseBillScannerIconPainter extends CustomPainter {
  const _PurchaseBillScannerIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35
      ..strokeCap = StrokeCap.round;

    final corner = size.width * 0.28;
    final inset = size.width * 0.12;

    void drawCorner({
      required Offset start,
      required Offset cornerPoint,
      required Offset end,
    }) {
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(cornerPoint.dx, cornerPoint.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, paint);
    }

    drawCorner(
      start: Offset(inset, inset + corner),
      cornerPoint: Offset(inset, inset),
      end: Offset(inset + corner, inset),
    );
    drawCorner(
      start: Offset(size.width - inset - corner, inset),
      cornerPoint: Offset(size.width - inset, inset),
      end: Offset(size.width - inset, inset + corner),
    );
    drawCorner(
      start: Offset(size.width - inset, size.height - inset - corner),
      cornerPoint: Offset(size.width - inset, size.height - inset),
      end: Offset(size.width - inset - corner, size.height - inset),
    );
    drawCorner(
      start: Offset(inset + corner, size.height - inset),
      cornerPoint: Offset(inset, size.height - inset),
      end: Offset(inset, size.height - inset - corner),
    );

    final centerY = size.height / 2;
    canvas.drawLine(
      Offset(size.width * 0.36, centerY),
      Offset(size.width * 0.64, centerY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _PurchaseBillScannerIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class UploadPurchaseBillsDialog extends ConsumerWidget {
  const UploadPurchaseBillsDialog({required this.hostContext, super.key});

  /// Page context under [MaterialApp.router] — used for routing after parse.
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: _dialogMaxWidth),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        clipBehavior: Clip.antiAlias,
        elevation: 12,
        shadowColor: const Color(0x33000000),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _DialogHeader(onClose: () => Navigator.of(context).pop()),
            const Divider(height: 1, color: _cardBorder),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useColumn = constraints.maxWidth < 560;
                  final desktopPanel = _UploadPanel(
                    icon: Icons.desktop_windows_outlined,
                    title: 'Upload From Desktop',
                    subtitle:
                        'Upload bill images or PDF files from your computer '
                        'and create purchase entries automatically.',
                    bullets: const [
                      'Upload purchase bills from your computer',
                      'Supports PDF, JPG, JPEG & PNG formats',
                      'Auto-extract party, items & tax details',
                    ],
                    actionLabel: 'Upload Bills',
                    filled: false,
                    onAction: () => runPurchaseDocumentDesktopImport(
                      context: hostContext,
                      onUploadModalClosed: () => Navigator.of(context).pop(),
                    ),
                  );
                  final mobilePanel = _UploadPanel(
                    icon: Icons.smartphone_outlined,
                    title: 'Import From Mobile',
                    subtitle:
                        'Scan purchase bills on your phone and sync them '
                        'to your desktop instantly.',
                    bullets: const [
                      'Scan bills using your phone camera',
                      'Bills sync automatically to desktop',
                      'Quick and paperless bill entry',
                    ],
                    actionLabel: 'Import from Mobile',
                    filled: true,
                    backgroundColor: _mobilePanelBg,
                    onAction: () => _showComingSoon(context, 'Mobile import'),
                  );

                  if (useColumn) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        desktopPanel,
                        const SizedBox(height: AppSpacing.md),
                        mobilePanel,
                      ],
                    );
                  }

                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: desktopPanel),
                        const VerticalDivider(
                          width: 1,
                          thickness: 1,
                          color: _cardBorder,
                        ),
                        Expanded(child: mobilePanel),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature coming soon')),
    );
  }
}

class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      child: Row(
        children: [
          const Text(
            'Upload Purchase Bills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close, size: 20),
            tooltip: 'Close',
            style: IconButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
                side: const BorderSide(color: _cardBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UploadPanel extends StatelessWidget {
  const _UploadPanel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bullets,
    required this.actionLabel,
    required this.filled,
    required this.onAction,
    this.backgroundColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> bullets;
  final String actionLabel;
  final bool filled;
  final VoidCallback onAction;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: AppRadius.mdBorder,
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: _iconBlueBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: _iconBlue, size: 28),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (final bullet in bullets) ...[
              _CheckBullet(text: bullet),
              const SizedBox(height: AppSpacing.sm),
            ],
            const SizedBox(height: AppSpacing.md),
            if (filled)
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  backgroundColor: _actionRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              OutlinedButton(
                onPressed: onAction,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _actionRed,
                  side: const BorderSide(color: _actionRed),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CheckBullet extends StatelessWidget {
  const _CheckBullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(top: 1),
          decoration: const BoxDecoration(
            color: _checkGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 12, color: Colors.white),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
