import 'package:billing_baba/features/sales/application/sales_service.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';
import 'package:billing_baba/features/sales/sales_constants.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sales_documents_by_type_provider.g.dart';

@riverpod
Future<List<SaleInvoiceModel>> salesDocumentsByType(
  Ref ref,
  SalesDocumentType documentType,
) async {
  final service = await ref.watch(salesServiceProvider.future);
  return service.fetchDocumentsByType(documentType);
}
