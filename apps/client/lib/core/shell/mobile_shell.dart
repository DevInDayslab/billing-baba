import 'package:flutter/material.dart';

class MobileShell extends StatelessWidget {
  const MobileShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Billing Baba')),
      body: child,
    );
  }
}
