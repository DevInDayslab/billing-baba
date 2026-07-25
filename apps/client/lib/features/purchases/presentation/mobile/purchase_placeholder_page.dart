import 'package:flutter/material.dart';

class MobilePurchasePlaceholderPage extends StatelessWidget {
  const MobilePurchasePlaceholderPage({
    super.key,
    required this.title,
    required this.route,
  });

  final String title;
  final String route;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Purchase Placeholder — Mobile UI coming soon'),
      ),
    );
  }
}
