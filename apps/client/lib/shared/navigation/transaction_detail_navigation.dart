import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Returns to the previous screen when the navigation stack allows it,
/// preserving list filters, search, scroll position, and tab selection.
/// Falls back to [fallbackRoute] when there is nothing to pop (e.g. deep link).
void returnToTransactionList(BuildContext context, String fallbackRoute) {
  if (context.canPop()) {
    context.pop();
    return;
  }
  context.go(fallbackRoute);
}
