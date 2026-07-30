import 'package:flutter/material.dart';

class MobileAccessDeniedPage extends StatelessWidget {
  const MobileAccessDeniedPage({
    super.key,
    this.fromRoute,
  });

  final String? fromRoute;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Access Denied — Mobile UI coming soon'),
      ),
    );
  }
}
