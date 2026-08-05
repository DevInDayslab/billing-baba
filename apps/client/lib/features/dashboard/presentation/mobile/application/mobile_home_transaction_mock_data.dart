import 'package:billing_baba/features/dashboard/presentation/mobile/application/mobile_home_models.dart';
import 'package:billing_baba/shared/widgets/mobile/transaction/mobile_transaction_mapper.dart';
import 'package:intl/intl.dart';

/// Sample transactions for the mobile home transaction feed when live data is empty.
abstract final class MobileHomeTransactionMockData {
  static List<MobileHomeTransactionItem> transactions() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateFormat = DateFormat('d MMM yyyy');

    return [
      _item(
        id: 'mock-sale-1',
        title: 'Cash Sale',
        partyName: 'Walk-in Customer',
        documentNumber: 'INV-000123',
        filterType: MobileHomeTransactionFilterType.sale,
        statusType: MobileHomeTransactionStatusType.salePaid,
        statusLabel: 'Paid',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(5250),
        paymentMethod: 'Cash',
        timeLabel: '10:30 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 10, minutes: 30)),
      ),
      _item(
        id: 'mock-purchase-1',
        title: 'Purchase from Raj Suppliers',
        partyName: 'Raj Suppliers',
        documentNumber: 'BILL-000987',
        filterType: MobileHomeTransactionFilterType.purchase,
        statusType: MobileHomeTransactionStatusType.purchase,
        statusLabel: 'Credit',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(12500),
        paymentMethod: 'Credit',
        timeLabel: '09:45 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 9, minutes: 45)),
      ),
      _item(
        id: 'mock-payment-in-1',
        title: 'Payment In from Mohan Traders',
        partyName: 'Mohan Traders',
        documentNumber: 'RCPT-000456',
        filterType: MobileHomeTransactionFilterType.paymentIn,
        statusType: MobileHomeTransactionStatusType.paymentIn,
        statusLabel: 'Received',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(15000),
        paymentMethod: 'UPI',
        timeLabel: '09:15 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 9, minutes: 15)),
      ),
      _item(
        id: 'mock-payment-out-1',
        title: 'Payment Out to S Kumar',
        partyName: 'S Kumar',
        documentNumber: 'PAY-000321',
        filterType: MobileHomeTransactionFilterType.paymentOut,
        statusType: MobileHomeTransactionStatusType.paymentOut,
        statusLabel: 'Paid',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(8000),
        paymentMethod: 'Bank Transfer',
        timeLabel: '08:50 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 8, minutes: 50)),
      ),
      _item(
        id: 'mock-sale-2',
        title: 'Cash Sale',
        partyName: 'Walk-in Customer',
        documentNumber: 'INV-000122',
        filterType: MobileHomeTransactionFilterType.sale,
        statusType: MobileHomeTransactionStatusType.salePaid,
        statusLabel: 'Paid',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(3750),
        paymentMethod: 'Cash',
        timeLabel: '07:30 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 7, minutes: 30)),
      ),
      _item(
        id: 'mock-sale-3',
        title: 'Bulk Sale',
        partyName: 'Metro Distributors',
        documentNumber: 'INV-000120',
        filterType: MobileHomeTransactionFilterType.sale,
        statusType: MobileHomeTransactionStatusType.salePaid,
        statusLabel: 'Paid',
        totalLabel: MobileTransactionMapper.formatHomeAmountIndian(245000),
        paymentMethod: 'Credit',
        timeLabel: '06:15 AM',
        dateLabel: dateFormat.format(today),
        transactionDate: today.add(const Duration(hours: 6, minutes: 15)),
      ),
    ];
  }

  static MobileHomeTransactionItem _item({
    required String id,
    required String title,
    required String partyName,
    required String documentNumber,
    required MobileHomeTransactionFilterType filterType,
    required MobileHomeTransactionStatusType statusType,
    required String statusLabel,
    required String totalLabel,
    required String paymentMethod,
    required String timeLabel,
    required String dateLabel,
    required DateTime transactionDate,
  }) {
    return MobileHomeTransactionItem(
      id: id,
      title: title,
      partyName: partyName,
      documentNumber: documentNumber,
      statusLabel: statusLabel,
      statusType: statusType,
      filterType: filterType,
      dateLabel: dateLabel,
      totalLabel: totalLabel,
      balanceLabel: 'Balance',
      balanceValueLabel: '₹0',
      paymentMethod: paymentMethod,
      timeLabel: timeLabel,
      transactionDate: transactionDate,
    );
  }
}
