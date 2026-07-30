import 'package:flutter/material.dart';

class MobileAddCreditNotePage extends StatelessWidget {
  const MobileAddCreditNotePage({
    super.key,
    this.creditNoteId,
    this.fromInvoiceId,
  });

  final String? creditNoteId;
  final String? fromInvoiceId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Credit Note — Mobile UI coming soon'),
      ),
    );
  }
}
