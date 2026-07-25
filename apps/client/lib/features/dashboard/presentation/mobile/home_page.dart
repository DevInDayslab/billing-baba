import 'package:flutter/material.dart';

/// Placeholder home shown inside [MobileShell] after authentication.
class MobileHomePage extends StatelessWidget {
  const MobileHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 56),
            SizedBox(height: 16),
            Text(
              'You are signed in',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Mobile home UI coming soon.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
