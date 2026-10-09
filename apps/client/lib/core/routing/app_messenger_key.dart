import 'package:flutter/material.dart';

/// Root [ScaffoldMessenger] for app-wide feedback (settings save toasts, etc.).
final rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>(
  debugLabel: 'rootScaffoldMessenger',
);
