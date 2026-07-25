import 'package:flutter/material.dart';

class MobileAddSalePage extends StatelessWidget {
  const MobileAddSalePage({
    super.key,
    this.invoiceId,
    this.duplicateFromId,
    this.attachOrderIds,
    this.readOnly = false,
  });

  final String? invoiceId;
  final String? duplicateFromId;
  final List<String>? attachOrderIds;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Sale — Mobile UI coming soon'),
      ),
    );
  }
}
