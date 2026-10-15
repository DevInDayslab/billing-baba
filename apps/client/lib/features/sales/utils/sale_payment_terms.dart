import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';

/// Invoice due date from invoice date + configured payment term days.
DateTime dueDateFromPaymentTerm({
  required DateTime invoiceDate,
  required String termName,
  required List<PaymentTermSetting> terms,
}) {
  final term = resolvePaymentTermSetting(termName, terms);
  final base = DateTime(invoiceDate.year, invoiceDate.month, invoiceDate.day);
  return base.add(Duration(days: term.days));
}

PaymentTermSetting resolvePaymentTermSetting(
  String termName,
  List<PaymentTermSetting> terms,
) {
  if (terms.isEmpty) {
    return TransactionFormExtras.defaultPaymentTerms().first;
  }
  for (final term in terms) {
    if (term.name == termName) return term;
  }
  for (final term in terms) {
    if (term.isDefault) return term;
  }
  return terms.first;
}
