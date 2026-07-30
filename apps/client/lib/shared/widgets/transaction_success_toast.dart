import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

const _toastBorderRadius = BorderRadius.all(Radius.circular(8));
const _toastDuration = Duration(seconds: 4);

/// Shows a small success note at the top-right of the screen.
void showTransactionSuccessToast(
  BuildContext context, {
  String message = 'Transaction completed successfully',
}) {
  _showCornerToast(
    context,
    message: message,
    icon: Icons.check_circle,
    foregroundColor: const Color(0xFF2E7D32),
    borderColor: const Color(0xFFA5D6A7),
    duration: const Duration(seconds: 3),
  );
}

/// Shows a dismissible error note at the top-right of the screen.
void showTransactionErrorToast(
  BuildContext context, {
  required String message,
  Duration duration = _toastDuration,
}) {
  _showCornerToast(
    context,
    message: message,
    icon: Icons.error_outline,
    foregroundColor: AppColors.error,
    borderColor: const Color(0xFFEF9A9A),
    duration: duration,
  );
}

void _showCornerToast(
  BuildContext context, {
  required String message,
  required IconData icon,
  required Color foregroundColor,
  required Color borderColor,
  required Duration duration,
}) {
  final overlay = Overlay.of(context, rootOverlay: true);
  late OverlayEntry entry;

  void dismiss() {
    if (entry.mounted) {
      entry.remove();
    }
  }

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 16,
      right: 16,
      child: Material(
        elevation: 4,
        shadowColor: Colors.black26,
        borderRadius: _toastBorderRadius,
        color: Colors.transparent,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: _toastBorderRadius,
            border: Border.all(color: borderColor),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: foregroundColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: foregroundColor,
                        height: 1.35,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: dismiss,
                    icon: Icon(Icons.close, color: foregroundColor, size: 18),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                    constraints: const BoxConstraints(
                      minWidth: 28,
                      minHeight: 28,
                    ),
                    tooltip: 'Dismiss',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  Future<void>.delayed(duration, dismiss);
}
