import 'package:flutter/material.dart';

/// Blocks concurrent Excel/CSV exports and shows a loading dialog for the
/// outermost export operation.
abstract final class ExportLoadingScope {
  static var _guardDepth = 0;
  static var _isExporting = false;

  static Future<T?> runGuarded<T>(
    BuildContext context,
    Future<T> Function() action,
  ) async {
    if (_guardDepth == 0 && _isExporting) return null;

    final isOuter = _guardDepth == 0;
    if (isOuter) {
      if (!context.mounted) return null;
      _isExporting = true;
      _showLoadingDialog(context);
      // Yield so the loading dialog can paint before heavy export work.
      await Future<void>.delayed(Duration.zero);
    }

    _guardDepth++;
    try {
      return await action();
    } finally {
      _guardDepth--;
      if (isOuter) {
        _isExporting = false;
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    }
  }

  static void _showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  SizedBox(height: 12),
                  Text('Exporting…'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
