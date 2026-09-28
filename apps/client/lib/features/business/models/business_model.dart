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
    this.gstin,
    this.ownerName,
    this.phone,
    this.email,
    this.address,
    this.role,
    this.logoUrl,
    this.scheduledDeletionAt,
  });

  final String id;
  final String name;
  final DateTime? lastSaleAt;
  final SyncStatus syncStatus;
  final bool isCurrent;
  final bool isShared;
  final String? gstin;
  final String? ownerName;
  final String? phone;
  final String? email;
  final String? address;
  final String? role;
  final String? logoUrl;
  final DateTime? scheduledDeletionAt;

  bool get isOwner => role == 'owner';

  bool get isPendingDeletion => scheduledDeletionAt != null;

  BusinessModel copyWith({
    String? id,
    String? name,
    DateTime? lastSaleAt,
    SyncStatus? syncStatus,
    bool? isCurrent,
    bool? isShared,
    String? gstin,
    String? ownerName,
    String? phone,
    String? email,
    String? address,
    String? role,
    String? logoUrl,
    DateTime? scheduledDeletionAt,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      lastSaleAt: lastSaleAt ?? this.lastSaleAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isCurrent: isCurrent ?? this.isCurrent,
      isShared: isShared ?? this.isShared,
      gstin: gstin ?? this.gstin,
      ownerName: ownerName ?? this.ownerName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      logoUrl: logoUrl ?? this.logoUrl,
      scheduledDeletionAt:
          scheduledDeletionAt ?? this.scheduledDeletionAt,
    );
  }
}
