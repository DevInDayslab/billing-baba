import 'package:billing_baba/core/widgets/adaptive_page.dart';
import './desktop/add_credit_note_page.dart';
import './mobile/add_credit_note_page.dart';
import 'package:flutter/widgets.dart';

class AddCreditNotePage extends StatelessWidget {
  const AddCreditNotePage({
    super.key,
    this.creditNoteId,
    this.fromInvoiceId,
  });

  final String? creditNoteId;
  final String? fromInvoiceId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: DesktopAddCreditNotePage(creditNoteId: creditNoteId, fromInvoiceId: fromInvoiceId),
      mobile: MobileAddCreditNotePage(creditNoteId: creditNoteId, fromInvoiceId: fromInvoiceId),
    );
  }
}
