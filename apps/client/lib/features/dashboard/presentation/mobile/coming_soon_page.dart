import 'package:flutter/material.dart';

class MobileComingSoonPage extends StatelessWidget {
  const MobileComingSoonPage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Coming Soon — Mobile UI coming soon'),
      ),
    );
  }
}
