import 'package:billing_baba/core/utils/date_time_utils.dart';
import 'package:billing_baba/features/parties/models/party_ledger_model.dart';

class PartyLedgerSummaryDto {
  const PartyLedgerSummaryDto({
    required this.openingBalance,
    required this.outstanding,
    required this.receiveAmount,
    required this.payableAmount,
    required this.status, required this.totalSales, required this.totalPurchases, required this.totalPayments, this.creditLimit,
    this.lastTransactionDate,
  });

  factory PartyLedgerSummaryDto.fromJson(Map<String, dynamic> json) {
    return PartyLedgerSummaryDto(
      openingBalance: json['opening_balance'] as String? ?? '0',
      outstanding: json['outstanding'] as String? ?? '0',
      receiveAmount: json['receive_amount'] as String? ?? '0',
      payableAmount: json['payable_amount'] as String? ?? '0',
      creditLimit: json['credit_limit'] as String?,
      status: json['status'] as String? ?? 'active',
      lastTransactionDate: json['last_transaction_date'] as String?,
      totalSales: json['total_sales'] as String? ?? '0',
      totalPurchases: json['total_purchases'] as String? ?? '0',
      totalPayments: json['total_payments'] as String? ?? '0',
    );
  }

  final String openingBalance;
  final String outstanding;
  final String receiveAmount;
  final String payableAmount;
  final String? creditLimit;
  final String status;
  final String? lastTransactionDate;
  final String totalSales;
  final String totalPurchases;
  final String totalPayments;
}

class PartyLedgerTransactionDto {
  const PartyLedgerTransactionDto({
    required this.id,
    required this.date,
    required this.createdAt,
    required this.type,
    required this.entryType,
    required this.debit, required this.credit, required this.balanceAfter, this.referenceId,
    this.referenceType,
    this.referenceNumber,
    this.description,
    this.direction,
  });

  factory PartyLedgerTransactionDto.fromJson(Map<String, dynamic> json) {
    return PartyLedgerTransactionDto(
      id: json['id'] as String,
      date: json['date'] as String,
      createdAt: json['created_at'] as String,
      type: json['type'] as String? ?? '',
      entryType: json['entry_type'] as String? ?? '',
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      referenceNumber: json['reference_number'] as String?,
      description: json['description'] as String?,
      debit: json['debit'] as String? ?? '0',
      credit: json['credit'] as String? ?? '0',
      balanceAfter: json['balance_after'] as String? ?? '0',
      direction: json['direction'] as String?,
    );
  }

  final String id;
  final String date;
  final String createdAt;
  final String type;
  final String entryType;
  final String? referenceId;
  final String? referenceType;
  final String? referenceNumber;
  final String? description;
  final String debit;
  final String credit;
  final String balanceAfter;
  final String? direction;
}

class PartyLedgerDto {
  const PartyLedgerDto({
    required this.partyId,
    required this.summary,
    required this.transactions,
  });

  factory PartyLedgerDto.fromJson(Map<String, dynamic> json) {
    final transactionsJson = json['transactions'];
    return PartyLedgerDto(
      partyId: json['party_id'] as String,
      summary: PartyLedgerSummaryDto.fromJson(
        json['summary'] as Map<String, dynamic>,
      ),
      transactions: transactionsJson is List
          ? transactionsJson
                .map(
                  (entry) => PartyLedgerTransactionDto.fromJson(
                    entry as Map<String, dynamic>,
                  ),
                )
                .toList()
          : const [],
    );
  }

  final String partyId;
  final PartyLedgerSummaryDto summary;
  final List<PartyLedgerTransactionDto> transactions;
}

class PartyLedgerMapper {
  static PartyLedgerModel toModel(PartyLedgerDto dto) {
    return PartyLedgerModel(
      partyId: dto.partyId,
      summary: PartyLedgerSummaryModel(
        openingBalance: double.tryParse(dto.summary.openingBalance) ?? 0,
        outstanding: double.tryParse(dto.summary.outstanding) ?? 0,
        receiveAmount: double.tryParse(dto.summary.receiveAmount) ?? 0,
        payableAmount: double.tryParse(dto.summary.payableAmount) ?? 0,
        creditLimit: dto.summary.creditLimit != null
            ? double.tryParse(dto.summary.creditLimit!)
            : null,
        isActive: dto.summary.status == 'active',
        lastTransactionDate: dto.summary.lastTransactionDate != null
            ? DateTime.tryParse(dto.summary.lastTransactionDate!)
            : null,
        totalSales: double.tryParse(dto.summary.totalSales) ?? 0,
        totalPurchases: double.tryParse(dto.summary.totalPurchases) ?? 0,
        totalPayments: double.tryParse(dto.summary.totalPayments) ?? 0,
      ),
      transactions: dto.transactions.map(toTransaction).toList(),
    );
  }

  static PartyLedgerTransactionModel toTransaction(
    PartyLedgerTransactionDto dto,
  ) {
    return PartyLedgerTransactionModel(
      id: dto.id,
      date: DateTimeUtils.parseApiDateTime(dto.date),
      createdAt: DateTimeUtils.parseApiDateTime(dto.createdAt),
      type: dto.type,
      entryType: dto.entryType,
      referenceId: dto.referenceId,
      referenceType: dto.referenceType,
      referenceNumber: dto.referenceNumber,
      description: dto.description,
      debit: double.tryParse(dto.debit) ?? 0,
      credit: double.tryParse(dto.credit) ?? 0,
      balanceAfter: double.tryParse(dto.balanceAfter) ?? 0,
      direction: dto.direction,
    );
  }
}
