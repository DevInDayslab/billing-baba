import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sale_screen/application/pos_bill_share_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

const _tintPurple = Color(0xFFF5F0FF);
const _whatsAppGreen = Color(0xFF25D366);
const _emailBlue = Color(0xFF4285F4);
/// Pick how to share the current draft bill (PDF / WhatsApp / email / more).
class SaleScreenShareBillDialog extends ConsumerStatefulWidget {
  const SaleScreenShareBillDialog({
    required this.cartSessionKey,
    super.key,
  });

  final String cartSessionKey;

  static Future<void> show(
    BuildContext context, {
    required String cartSessionKey,
  }) {
    return showDialog<void>(
      context: context,
      builder: (context) => SaleScreenShareBillDialog(
        cartSessionKey: cartSessionKey,
      ),
    );
  }

  @override
  ConsumerState<SaleScreenShareBillDialog> createState() =>
      _SaleScreenShareBillDialogState();
}

class _SaleScreenShareBillDialogState
    extends ConsumerState<SaleScreenShareBillDialog> {
  var _busy = false;

  Future<void> _onOption(PosBillShareOption option) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await PosBillShareHandler.shareFromCartSession(
        context: context,
        ref: ref,
        cartSessionKey: widget.cartSessionKey,
        option: option,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      alignment: Alignment.center,
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.lgBorder),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _tintPurple,
                      borderRadius: AppRadius.mdBorder,
                    ),
                    child: const Icon(
                      LucideIcons.share2,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share bill',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose how you want to send this bill.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
            if (_busy)
              const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.lg),
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  0,
                  AppSpacing.lg,
                  AppSpacing.lg,
                ),
                child: Column(
                  children: [
                    _ShareBillOptionTile(
                      icon: Icons.picture_as_pdf_outlined,
                      iconColor: AppColors.error,
                      iconBackground: const Color(0xFFFFEBEE),
                      title: PosBillShareOption.savePdf.title,
                      subtitle: PosBillShareOption.savePdf.subtitle,
                      onTap: () => _onOption(PosBillShareOption.savePdf),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ShareBillOptionTile(
                      icon: Icons.chat_outlined,
                      iconColor: _whatsAppGreen,
                      iconBackground: const Color(0xFFE8F8EF),
                      title: PosBillShareOption.whatsApp.title,
                      subtitle: PosBillShareOption.whatsApp.subtitle,
                      onTap: () => _onOption(PosBillShareOption.whatsApp),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ShareBillOptionTile(
                      icon: Icons.email_outlined,
                      iconColor: _emailBlue,
                      iconBackground: const Color(0xFFE8F0FE),
                      title: PosBillShareOption.email.title,
                      subtitle: PosBillShareOption.email.subtitle,
                      onTap: () => _onOption(PosBillShareOption.email),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _ShareBillOptionTile(
                      icon: Icons.apps_outlined,
                      iconColor: AppColors.primary,
                      iconBackground: _tintPurple,
                      title: PosBillShareOption.moreApps.title,
                      subtitle: PosBillShareOption.moreApps.subtitle,
                      onTap: () => _onOption(PosBillShareOption.moreApps),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ShareBillOptionTile extends StatelessWidget {
  const _ShareBillOptionTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: const Color(0xFFE8E8E8)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: AppRadius.mdBorder,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
