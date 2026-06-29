import 'package:flutter/foundation.dart';

/// Represents a business the user can select during onboarding.
@immutable
class BusinessModel {
  const BusinessModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.gstin,
    required this.phone,
    required this.lastOpenedAt,
    this.isShared = false,
    this.isOfflineReady = true,
  });

  final String id;
  final String name;
  final String ownerName;
  final String gstin;
  final String phone;
  final DateTime lastOpenedAt;
  final bool isShared;
  final bool isOfflineReady;

  BusinessModel copyWith({
    String? id,
    String? name,
    String? ownerName,
    String? gstin,
    String? phone,
    DateTime? lastOpenedAt,
    bool? isShared,
    bool? isOfflineReady,
  }) {
    return BusinessModel(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerName: ownerName ?? this.ownerName,
      gstin: gstin ?? this.gstin,
      phone: phone ?? this.phone,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      isShared: isShared ?? this.isShared,
      isOfflineReady: isOfflineReady ?? this.isOfflineReady,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
