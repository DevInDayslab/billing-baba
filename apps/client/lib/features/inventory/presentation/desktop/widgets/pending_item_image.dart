import 'dart:typed_data';

/// Local optimistic thumbnail while an item-image upload is in flight.
class PendingItemImage {
  const PendingItemImage({
    required this.localId,
    required this.bytes,
    this.replacesImageId,
    this.isPrimary = false,
  });

  final String localId;
  final Uint8List bytes;
  final String? replacesImageId;
  final bool isPrimary;
}
