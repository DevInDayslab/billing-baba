class HiddenLedgerEntryModel {
  const HiddenLedgerEntryModel({
    required this.id,
    required this.partyId,
    required this.amount,
    required this.recoveredAmount,
    required this.remainingAmount,
    required this.status,
    this.partyName,
    this.saleId,
    this.invoiceId,
    this.invoiceNumber,
    this.createdAt,
  });

  factory HiddenLedgerEntryModel.fromJson(Map<String, dynamic> json) {
    return HiddenLedgerEntryModel(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String?,
      saleId: json['sale_id'] as String?,
      invoiceId: json['invoice_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      recoveredAmount:
          double.tryParse(json['recovered_amount']?.toString() ?? '0') ?? 0,
      remainingAmount: _readRemainingAmount(json),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String partyId;
  final String? partyName;
  final String? saleId;
  final String? invoiceId;
  final String? invoiceNumber;
  final double amount;
  final double recoveredAmount;
  final double remainingAmount;
  final String status;
  final DateTime? createdAt;

  bool get isOpen =>
      status == 'pending' || status == 'partial' || status == 'open';

  String get statusLabel {
    return switch (status) {
      'partial' => 'Partial',
      'recovered' => 'Recovered',
      _ => 'Pending',
    };
  }

  static double _readRemainingAmount(Map<String, dynamic> json) {
    final remaining = json['remaining_amount'] ?? json['outstanding_amount'];
    return double.tryParse(remaining?.toString() ?? '0') ?? 0;
  }
}

class HiddenLedgerEntryDetailModel extends HiddenLedgerEntryModel {
  const HiddenLedgerEntryDetailModel({
    required super.id,
    required super.partyId,
    required super.amount,
    required super.recoveredAmount,
    required super.remainingAmount,
    required super.status,
    required this.recoveries,
    super.partyName,
    super.saleId,
    super.invoiceId,
    super.invoiceNumber,
    super.createdAt,
  });

  factory HiddenLedgerEntryDetailModel.fromJson(Map<String, dynamic> json) {
    final recoveries = (json['recoveries'] as List<dynamic>? ?? [])
        .map(
          (item) => HiddenLedgerRecoveryModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    return HiddenLedgerEntryDetailModel(
      id: json['id'] as String,
      partyId: json['party_id'] as String,
      partyName: json['party_name'] as String?,
      saleId: json['sale_id'] as String?,
      invoiceId: json['invoice_id'] as String?,
      invoiceNumber: json['invoice_number'] as String?,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0,
      recoveredAmount:
          double.tryParse(json['recovered_amount']?.toString() ?? '0') ?? 0,
      remainingAmount: HiddenLedgerEntryModel._readRemainingAmount(json),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      recoveries: recoveries,
    );
  }

  final List<HiddenLedgerRecoveryModel> recoveries;
}

class HiddenLedgerPartySummaryModel {
  const HiddenLedgerPartySummaryModel({
    required this.partyId,
    required this.hiddenLedgerBalance,
    required this.pendingEntries,
    required this.totalRemaining,
  });

  factory HiddenLedgerPartySummaryModel.fromJson(Map<String, dynamic> json) {
    return HiddenLedgerPartySummaryModel(
      partyId: json['party_id'] as String,
      hiddenLedgerBalance: _readBalance(json),
      pendingEntries:
          json['pending_entries'] as int? ?? json['open_entries'] as int? ?? 0,
      totalRemaining: _readTotalRemaining(json),
    );
  }

  final String partyId;
  final double hiddenLedgerBalance;
  final int pendingEntries;
  final double totalRemaining;

  static double _readBalance(Map<String, dynamic> json) {
    final balance = json['hidden_ledger_balance'] ?? json['unrecovered_amount'];
    return double.tryParse(balance?.toString() ?? '0') ?? 0;
  }

  static double _readTotalRemaining(Map<String, dynamic> json) {
    final total = json['total_remaining'] ?? json['total_outstanding'];
    return double.tryParse(total?.toString() ?? '0') ?? 0;
  }
}

class HiddenLedgerRecoveryModel {
  const HiddenLedgerRecoveryModel({
    required this.id,
    required this.ledgerEntryId,
    required this.recoveredAmount,
    this.saleId,
    this.recoveredBy,
    this.createdAt,
  });

  factory HiddenLedgerRecoveryModel.fromJson(Map<String, dynamic> json) {
    return HiddenLedgerRecoveryModel(
      id: json['id'] as String,
      ledgerEntryId:
          json['ledger_entry_id'] as String? ?? json['entry_id'] as String? ?? '',
      saleId: json['sale_id'] as String?,
      recoveredAmount: double.tryParse(
            json['recovered_amount']?.toString() ??
                json['amount']?.toString() ??
                '0',
          ) ??
          0,
      recoveredBy: json['recovered_by'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
    );
  }

  final String id;
  final String ledgerEntryId;
  final String? saleId;
  final double recoveredAmount;
  final String? recoveredBy;
  final DateTime? createdAt;
}
