import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/add_debit_note_page.dart';
import 'package:billing_baba/features/purchases/presentation/mobile/add_debit_note_page.dart';
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
