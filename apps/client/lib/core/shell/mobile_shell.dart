import 'package:flutter/material.dart';

/// Minimal authenticated landing shell for mobile.
///
/// Bottom navigation is intentionally deferred — this only hosts the routed
/// child after Splash → Login → OTP (and company selection when required).
class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Baba'),
      ),
      body: child,
    );
  }
}
