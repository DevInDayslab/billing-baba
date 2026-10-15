class LoanAccountDto {
  const LoanAccountDto({
    required this.id,
    required this.name,
    this.lenderName,
    this.accountNumber,
    this.description,
    required this.openingOutstanding,
    required this.openingBalanceAsOf,
    this.interestRate,
    this.termMonths,
    this.receivedBankAccountId,
  });

  factory LoanAccountDto.fromJson(Map<String, dynamic> json) {
    return LoanAccountDto(
      id: json['id'] as String,
      name: json['name'] as String? ?? '',
      lenderName: json['lender_name'] as String?,
      accountNumber: json['account_number'] as String?,
      description: json['description'] as String?,
      openingOutstanding: json['opening_outstanding'] as String? ?? '0',
      openingBalanceAsOf:
          json['opening_balance_as_of'] as String? ?? '1970-01-01',
      interestRate: json['interest_rate'] as String?,
      termMonths: json['term_months'] as int?,
      receivedBankAccountId: json['received_bank_account_id'] as String?,
    );
  }

  final String id;
  final String name;
  final String? lenderName;
  final String? accountNumber;
  final String? description;
  final String openingOutstanding;
  final String openingBalanceAsOf;
  final String? interestRate;
  final int? termMonths;
  final String? receivedBankAccountId;

  String get displayLabel {
    if (lenderName != null && lenderName!.trim().isNotEmpty) {
      return '$name · ${lenderName!.trim()}';
    }
    return name;
  }

  Map<String, dynamic> toSyncPayload() => {
    'name': name,
    if (lenderName != null) 'lender_name': lenderName,
    if (accountNumber != null) 'account_number': accountNumber,
    if (description != null) 'description': description,
    'opening_outstanding': openingOutstanding,
    'opening_balance_as_of': openingBalanceAsOf,
    if (interestRate != null) 'interest_rate': interestRate,
    if (termMonths != null) 'term_months': termMonths,
    if (receivedBankAccountId != null)
      'received_bank_account_id': receivedBankAccountId,
  };
}

enum LoanTransactionType {
  increase('increase'),
  repayment('repayment'),
  charges('charges');

  const LoanTransactionType(this.apiValue);

  final String apiValue;

  String get label => switch (this) {
    LoanTransactionType.increase => 'Loan increase',
    LoanTransactionType.repayment => 'Repayment',
    LoanTransactionType.charges => 'Charges',
  };

  static LoanTransactionType? fromApi(String? value) {
    return switch (value) {
      'increase' => LoanTransactionType.increase,
      'repayment' => LoanTransactionType.repayment,
      'charges' => LoanTransactionType.charges,
      _ => null,
    };
  }
}

class LoanTransactionDto {
  const LoanTransactionDto({
    required this.id,
    required this.loanAccountId,
    this.loanAccountName,
    required this.transactionType,
    required this.transactionDate,
    required this.principalAmount,
    required this.interestAmount,
    required this.chargesAmount,
    required this.bankAccountId,
    this.description,
    this.referenceNumber,
  });

  factory LoanTransactionDto.fromJson(Map<String, dynamic> json) {
    return LoanTransactionDto(
      id: json['id'] as String,
      loanAccountId: json['loan_account_id'] as String,
      loanAccountName: json['loan_account_name'] as String?,
      transactionType: json['transaction_type'] as String? ?? 'increase',
      transactionDate: json['transaction_date'] as String? ?? '',
      principalAmount: json['principal_amount'] as String? ?? '0',
      interestAmount: json['interest_amount'] as String? ?? '0',
      chargesAmount: json['charges_amount'] as String? ?? '0',
      bankAccountId: json['bank_account_id'] as String,
      description: json['description'] as String?,
      referenceNumber: json['reference_number'] as String?,
    );
  }

  final String id;
  final String loanAccountId;
  final String? loanAccountName;
  final String transactionType;
  final String transactionDate;
  final String principalAmount;
  final String interestAmount;
  final String chargesAmount;
  final String bankAccountId;
  final String? description;
  final String? referenceNumber;

  LoanTransactionType? get type => LoanTransactionType.fromApi(transactionType);

  String get typeLabel => type?.label ?? transactionType;

  double get totalAmount {
    final p = double.tryParse(principalAmount) ?? 0;
    final i = double.tryParse(interestAmount) ?? 0;
    final c = double.tryParse(chargesAmount) ?? 0;
    return p + i + c;
  }
}
