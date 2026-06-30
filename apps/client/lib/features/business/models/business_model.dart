enum SyncStatus {
  on,
  off,
}

class BusinessModel {
  const BusinessModel({
    required this.id,
    required this.name,
    required this.syncStatus,
    this.lastSaleAt,
    this.isCurrent = false,
    this.isShared = false,
  });

  final String id;
  final String name;
  final DateTime? lastSaleAt;
  final SyncStatus syncStatus;
  final bool isCurrent;
  final bool isShared;

  BusinessModel copyWith({
    String? id,
    String? name,
    DateTime? lastSaleAt,
    SyncStatus? syncStatus,
    bool? isCurrent,
    bool? isShared,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastSaleAt: lastSaleAt ?? this.lastSaleAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isCurrent: isCurrent ?? this.isCurrent,
      isShared: isShared ?? this.isShared,
    );
  }
}
