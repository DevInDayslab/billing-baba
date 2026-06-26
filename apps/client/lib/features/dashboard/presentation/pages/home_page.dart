import 'package:billing_baba/core/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Home',
      body: Center(child: Text('Dashboard')),
    );
  }
}
