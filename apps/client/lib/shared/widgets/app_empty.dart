import 'package:flutter/material.dart';

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    this.title = 'No data',
    this.message,
    this.action,
  });

  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          if (message != null) ...[const SizedBox(height: 8), Text(message!)],
          if (action != null) ...[const SizedBox(height: 16), action!],
        ],
      ),
    );
  }
}
