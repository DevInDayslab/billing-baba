import 'package:billing_baba/core/widgets/adaptive_page.dart';
import 'package:billing_baba/features/sales/presentation/desktop/add_credit_note_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_credit_note_page.dart';
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
