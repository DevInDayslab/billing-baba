/// Internal timeline row used to build party ledger transactions offline.
class PartyTimelineRow {
  const PartyTimelineRow({
    required this.id,
    required this.source,
    required this.sourceType,
    required this.type,
    required this.referenceId,
    required this.referenceType,
    required this.createdAt,
    required this.documentDate,
    required this.total,
    required this.balance,
    this.referenceNumber,
    this.dueDate,
    this.status,
    this.paymentStatus,
    this.direction,
  });

  final String id;
  final String source;
  final String sourceType;
  final String type;
  final String referenceId;
  final String referenceType;
  final String? referenceNumber;
  final DateTime createdAt;
  final DateTime documentDate;
  final String? dueDate;
  final double total;
  final double balance;
  final String? status;
  final String? paymentStatus;
  final String? direction;
}
