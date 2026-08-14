import 'package:billing_baba/features/sales/application/sale_document_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_document_model.dart';
import 'package:billing_baba/features/sales/presentation/desktop/proforma_invoice_page.dart';
import 'package:billing_baba/features/sales/presentation/mobile/add_proforma_page.dart';
import 'package:billing_baba/shared/widgets/adaptive_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddProformaPage extends StatelessWidget {
  const AddProformaPage({
    super.key,
    this.proformaId,
    this.duplicateFromId,
  });

  final String? proformaId;
  final String? duplicateFromId;

  @override
  Widget build(BuildContext context) {
    return AdaptivePage(
      desktop: _DesktopAddProformaPage(
        proformaId: proformaId,
        duplicateFromId: duplicateFromId,
      ),
      mobile: MobileAddProformaPage(
        proformaId: proformaId,
        duplicateFromId: duplicateFromId,
      ),
    );
  }
}

class _DesktopAddProformaPage extends ConsumerStatefulWidget {
  const _DesktopAddProformaPage({
    this.proformaId,
    this.duplicateFromId,
  });

  final String? proformaId;
  final String? duplicateFromId;

  @override
  ConsumerState<_DesktopAddProformaPage> createState() =>
      _DesktopAddProformaPageState();
}

class _DesktopAddProformaPageState
    extends ConsumerState<_DesktopAddProformaPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(
        saleDocumentFormProvider(SaleDocumentType.proforma).notifier,
      );
      if (widget.duplicateFromId != null) {
        await notifier.duplicateDocument(widget.duplicateFromId!);
      } else if (widget.proformaId != null) {
        await notifier.loadDocument(widget.proformaId!);
      } else {
        notifier.openForm();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const DesktopProformaInvoicePage();
  }
}
