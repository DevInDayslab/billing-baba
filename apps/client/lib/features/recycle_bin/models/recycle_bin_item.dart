class RecycleBinItem {
  const RecycleBinItem({
    required this.entityType,
    required this.entityId,
    required this.label,
    this.partyName,
    this.amount,
    this.transactionDate,
    required this.deletedAt,
    required this.daysRemaining,
  });

  final String entityType;
  final String entityId;
  final String label;
  final String? partyName;
  final String? amount;
  final String? transactionDate;
  final DateTime deletedAt;
  final int daysRemaining;

  factory RecycleBinItem.fromJson(Map<String, dynamic> json) {
    return RecycleBinItem(
      entityType: json['entity_type'] as String,
      entityId: json['entity_id'] as String,
      label: json['label'] as String? ?? '',
      partyName: json['party_name'] as String?,
      amount: json['amount'] as String?,
      transactionDate: json['transaction_date'] as String?,
      deletedAt: DateTime.parse(json['deleted_at'] as String),
      daysRemaining: (json['days_remaining'] as num?)?.toInt() ?? 0,
    );
  }
}
