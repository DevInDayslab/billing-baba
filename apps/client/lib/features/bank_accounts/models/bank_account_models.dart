class BankAccountDto {
  const BankAccountDto({
    required this.id,
    required this.type,
    required this.displayName,
    this.bankName,
    this.accountNumber,
    this.ifsc,
    this.upiId,
    required this.openingBalance,
    required this.openingBalanceAsOf,
    required this.isDefault,
    required this.isActive,
  });

  factory BankAccountDto.fromJson(Map<String, dynamic> json) {
    return BankAccountDto(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'bank',
      displayName: json['display_name'] as String? ?? '',
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifsc: json['ifsc'] as String?,
      upiId: json['upi_id'] as String?,
      openingBalance: json['opening_balance'] as String? ?? '0',
      openingBalanceAsOf:
          json['opening_balance_as_of'] as String? ?? '1970-01-01',
      isDefault: json['is_default'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  final String id;
  final String type;
  final String displayName;
  final String? bankName;
  final String? accountNumber;
  final String? ifsc;
  final String? upiId;
  final String openingBalance;
  final String openingBalanceAsOf;
  final bool isDefault;
  final bool isActive;

  bool get isCash => type == 'cash';

  String get label =>
      isCash ? displayName : (bankName?.isNotEmpty == true ? bankName! : displayName);

  Map<String, dynamic> toSyncPayload() => {
    'type': type,
    'display_name': displayName,
    if (bankName != null) 'bank_name': bankName,
    if (accountNumber != null) 'account_number': accountNumber,
    if (ifsc != null) 'ifsc': ifsc,
    if (upiId != null) 'upi_id': upiId,
    'opening_balance': openingBalance,
    'opening_balance_as_of': openingBalanceAsOf,
    'is_default': isDefault,
    'is_active': isActive,
  };
}

class BankAccountBalanceDto {
  const BankAccountBalanceDto({
    required this.accountId,
    required this.type,
    required this.displayName,
    required this.isActive,
    required this.balance,
  });

  factory BankAccountBalanceDto.fromJson(Map<String, dynamic> json) {
    return BankAccountBalanceDto(
      accountId: json['account_id'] as String,
      type: json['type'] as String? ?? 'bank',
      displayName: json['display_name'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      balance: json['balance'] as String? ?? '0',
    );
  }

  final String accountId;
  final String type;
  final String displayName;
  final bool isActive;
  final String balance;
}
