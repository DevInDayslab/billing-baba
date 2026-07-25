import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _logPrefix = '[PurchaseParse]';

/// Centered loading dialog shown while a purchase bill document is parsed.
class PurchaseDocumentParsingDialog extends StatelessWidget {
  const PurchaseDocumentParsingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Material(
        elevation: 8,
        borderRadius: AppRadius.lgBorder,
        color: AppColors.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'Uploading & parsing document...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'This may take up to a minute for large bills.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

NavigatorState? _parsingDialogNavigator;

bool get isPurchaseDocumentParsingDialogVisible =>
    _parsingDialogNavigator != null;

/// Shows the parsing loader. Do not await — [showDialog] completes only when
/// the route is popped, which would block the upload/parse work.
void showPurchaseDocumentParsingDialog(BuildContext context) {
  final navigator = Navigator.of(context, rootNavigator: true);
  _parsingDialogNavigator = navigator;
  debugPrint('$_logPrefix show parsing dialog');

  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: const Color(0x99000000),
    builder: (dialogContext) => const PurchaseDocumentParsingDialog(),
  ).whenComplete(() {
    debugPrint('$_logPrefix parsing dialog route completed');
    _parsingDialogNavigator = null;
  });
}

/// Dismisses the parsing loader if it is still on the navigator stack.
Future<bool> hidePurchaseDocumentParsingDialog([
  NavigatorState? navigator,
]) async {
  final nav = navigator ?? _parsingDialogNavigator;
  if (nav == null) {
    debugPrint('$_logPrefix hide parsing dialog: no navigator reference');
    return false;
  }
  if (!nav.mounted) {
    debugPrint('$_logPrefix hide parsing dialog: navigator not mounted');
    _parsingDialogNavigator = null;
    return false;
  }

  final popped = await nav.maybePop();
  debugPrint('$_logPrefix hide parsing dialog: maybePop=$popped');
  if (popped) {
    _parsingDialogNavigator = null;
  }
  return popped;
}

Future<bool?> showPurchaseDocumentParseErrorDialog(
  BuildContext context, {
  required String message,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Could not parse document'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Enter manually'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
