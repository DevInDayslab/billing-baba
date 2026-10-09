import 'package:flutter/material.dart';

/// Root navigator for [GoRouter] — used for app-wide overlays (e.g. settings toasts).
final rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'rootNavigator',
);
