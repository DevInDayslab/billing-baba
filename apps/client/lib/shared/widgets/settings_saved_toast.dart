import 'dart:math' as math;

import 'package:billing_baba/core/platform/app_platform.dart';
import 'package:billing_baba/core/routing/app_navigator_key.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const _toastDuration = Duration(seconds: 4);
const _horizontalInset = 16.0;
const _maxToastWidth = 420.0;

OverlayEntry? _activeSettingsToastEntry;

/// Vyapar-style success banner at the top-right (solid theme success color).
void showSettingsSavedToast({
  required String message,
  BuildContext? context,
  Duration duration = _toastDuration,
}) {
  final overlay = _resolveOverlay(context);
  if (overlay == null) {
    if (kDebugMode) {
      debugPrint('SettingsSavedToast: no overlay ($message)');
    }
    return;
  }

  _activeSettingsToastEntry?.remove();
  _activeSettingsToastEntry = null;

  late OverlayEntry entry;

  void dismiss() {
    if (entry.mounted) {
      entry.remove();
    }
    if (_activeSettingsToastEntry == entry) {
      _activeSettingsToastEntry = null;
    }
  }

  entry = OverlayEntry(
    builder: (overlayContext) {
      final size = MediaQuery.sizeOf(overlayContext);
      final padding = MediaQuery.paddingOf(overlayContext);
      final topBar = AppPlatform.current.isDesktop ? 56.0 : 8.0;
      final top = padding.top + topBar;
      final availableWidth = size.width - (_horizontalInset * 2);
      final toastWidth = math.min(_maxToastWidth, availableWidth);

      return Positioned(
        top: top,
        right: _horizontalInset,
        width: toastWidth,
        child: Material(
          elevation: 8,
          shadowColor: Colors.black26,
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          color: AppColors.success,
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
            child: _SettingsSavedToastBody(
              message: message,
              onDismiss: dismiss,
            ),
          ),
        ),
      );
    },
  );

  _activeSettingsToastEntry = entry;
  overlay.insert(entry);
  Future<void>.delayed(duration, dismiss);
}

class _SettingsSavedToastBody extends StatelessWidget {
  const _SettingsSavedToastBody({
    required this.message,
    required this.onDismiss,
  });

  final String message;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check, color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: AppTypography.inter(
              fontSize: AppTypography.bodyMediumSize,
              fontWeight: FontWeight.w500,
              color: Colors.white,
              height: 1.35,
            ),
          ),
        ),
        IconButton(
          onPressed: onDismiss,
          icon: const Icon(Icons.close, color: Colors.white, size: 18),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          tooltip: 'Dismiss',
        ),
      ],
    );
  }
}

OverlayState? _resolveOverlay(BuildContext? context) {
  if (context != null && context.mounted) {
    final fromContext = Overlay.maybeOf(context, rootOverlay: true);
    if (fromContext != null) return fromContext;
  }

  final navigator = rootNavigatorKey.currentState;
  if (navigator?.overlay != null) {
    return navigator!.overlay;
  }

  final navContext = rootNavigatorKey.currentContext;
  if (navContext != null && navContext.mounted) {
    return Overlay.maybeOf(navContext, rootOverlay: true);
  }

  return null;
}
