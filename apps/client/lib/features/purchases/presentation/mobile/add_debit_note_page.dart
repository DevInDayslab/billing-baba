import 'package:flutter/material.dart';

class MobileAddDebitNotePage extends StatelessWidget {
  const MobileAddDebitNotePage({
    super.key,
    this.debitNoteId,
  });

  final String? debitNoteId;

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Add Debit Note — Mobile UI coming soon'),
      ),
    );
  }
}
