import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Returns to the previous screen when the navigation stack allows it,
/// preserving list filters, search, scroll position, and tab selection.
/// Falls back to [fallbackRoute] when there is nothing to pop (e.g. deep link).
///
/// Uses an explicit [Navigator.pop] (not maybePop) so it still leaves forms
/// wrapped in `PopScope(canPop: false)`.
void returnToTransactionList(BuildContext context, String fallbackRoute) {
  final route = ModalRoute.of(context);
  if (route != null && !route.isFirst) {
    Navigator.of(context).pop();
    return;
  }
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallbackRoute);
}
