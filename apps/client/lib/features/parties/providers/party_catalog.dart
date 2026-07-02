import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_transaction_model.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_model.dart';

abstract final class PartyCatalog {
  static const partyNames = [
    'Sharma Traders',
    'Patel Electronics',
    'Gupta General Store',
    'Mehta Hardware',
    'Singh & Sons',
    'Kumar Agencies',
    'Reddy Mart',
    'Joshi Distributors',
    'Verma Enterprises',
    'Agarwal Textiles',
    'Bansal Pharma',
    'Chopra Foods',
  ];

  static const _balances = [
    18500.0,
    -12400.0,
    0.0,
    28750.0,
    -5600.0,
    9200.0,
    -18300.0,
    4500.0,
    0.0,
    -7200.0,
    15600.0,
    -3400.0,
  ];

  static const _activeFlags = [
    true,
    true,
    true,
    false,
    true,
    false,
    true,
    true,
    false,
    true,
    true,
    false,
  ];

  static final List<PartyModel> parties = [
    for (var i = 0; i < partyNames.length; i++)
      PartyModel(
        id: 'party-${i + 1}',
        name: partyNames[i],
        phone: _phones[i % _phones.length],
        balance: _balances[i % _balances.length],
        isActive: _activeFlags[i % _activeFlags.length],
      ),
  ];

  static List<PartyTransactionModel> transactions() => _buildTransactions();

  static const _phones = [
    '+91 98765 43210',
    '+91 91234 56789',
    '+91 99887 76655',
    '+91 90123 45678',
    '+91 97654 32109',
    '+91 93456 78901',
    '+91 98901 23456',
    '+91 94567 89012',
    '+91 92345 67890',
    '+91 96789 01234',
    '+91 98123 45670',
    '+91 95678 90123',
  ];

  static const _paymentTypes = ['Cash', 'Credit', 'UPI', 'Cheque'];

  static List<PartyTransactionModel> _buildTransactions() {
    final transactions = <PartyTransactionModel>[];
    var txnId = 1;

    for (var partyIndex = 0; partyIndex < parties.length; partyIndex++) {
      final party = parties[partyIndex];
      final txnCount = 3 + (partyIndex % 4);

      for (var i = 0; i < txnCount; i++) {
        final month = 3 + ((partyIndex + i) % 5);
        final day = ((partyIndex * 3 + i * 5) % 28) + 1;
        final status = SaleInvoiceStatus.values[(partyIndex + i) % 5];
        final amount = 2500 + ((txnId * 830) % 22000).toDouble();
        final balance = switch (status) {
          SaleInvoiceStatus.paid => 0.0,
          SaleInvoiceStatus.cancelled => 0.0,
          SaleInvoiceStatus.unpaid => amount,
          SaleInvoiceStatus.overdue => amount,
          SaleInvoiceStatus.partiallyPaid =>
            (amount * 0.45).roundToDouble(),
        };

        transactions.add(
          PartyTransactionModel(
            id: 'txn-$txnId',
            partyId: party.id,
            invoiceNo: 'SI-${1000 + txnId}',
            date: DateTime(2026, month, day, 10 + (i % 8), 30),
            transactionType: i.isEven ? 'Sale' : 'Payment In',
            paymentType: _paymentTypes[txnId % _paymentTypes.length],
            status: status,
            amount: amount,
            balance: balance,
          ),
        );
        txnId++;
      }
    }

    return transactions;
  }
}
