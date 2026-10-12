import 'dart:typed_data';

import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:crypto/crypto.dart';

const _walkInNamespace = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

Uint8List _uuidToBytes(String uuid) {
  final hex = uuid.replaceAll('-', '');
  return Uint8List.fromList(
    List.generate(hex.length ~/ 2, (i) {
      return int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }),
  );
}

String _bytesToUuid(Uint8List bytes) {
  final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
      '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
}

/// Deterministic walk-in party id scoped to a business (matches API).
String walkInPartyIdForBusiness(String businessId) {
  final namespace = _uuidToBytes(_walkInNamespace);
  final digest = sha1.convert([
    ...namespace,
    ...'billing-baba:walk-in-party:$businessId'.codeUnits,
  ]).bytes;
  final bytes = Uint8List.fromList(digest.sublist(0, 16));
  bytes[6] = (bytes[6] & 0x0f) | 0x50;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  return _bytesToUuid(bytes);
}

bool isWalkInPartyId(String businessId, String? partyId) {
  if (partyId == null || partyId.isEmpty) return false;
  return partyId == PosConstants.walkInPartyId ||
      partyId == walkInPartyIdForBusiness(businessId);
}

bool isWalkInPartyName(String name) {
  return name.trim().toLowerCase() ==
      PosConstants.walkInCustomerLabel.toLowerCase();
}

bool isWalkInCartCustomerName(String? customerName) {
  final trimmed = customerName?.trim();
  return trimmed == null || trimmed.isEmpty || isWalkInPartyName(trimmed);
}
