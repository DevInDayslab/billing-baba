import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_debit_note_page.dart';
import './mobile/add_debit_note_page.dart';
import 'package:flutter/widgets.dart';

class AddDebitNotePage extends StatelessWidget {
  const AddDebitNotePage({
    super.key,
    this.debitNoteId,
  });

  final String? debitNoteId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddDebitNotePage(debitNoteId: debitNoteId),
      mobile: MobileAddDebitNotePage(debitNoteId: debitNoteId),
    );
  }
}
