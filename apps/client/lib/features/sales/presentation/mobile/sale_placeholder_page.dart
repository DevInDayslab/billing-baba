import 'package:flutter/material.dart';

class MobileSalePlaceholderPage extends StatelessWidget {
  const MobileSalePlaceholderPage({
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
        child: Text('Sale Placeholder — Mobile UI coming soon'),
      ),
    );
  }
}
