import 'package:flutter/material.dart';

class MobileAddEstimatePage extends StatelessWidget {
  const MobileAddEstimatePage({
    super.key,
    this.estimateId,
    this.duplicateFromId,
  });

  final String? estimateId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Estimate — Mobile UI coming soon'),
      ),
    );
  }
}
