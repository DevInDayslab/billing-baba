/// POS-specific constants.
abstract final class PosConstants {
  /// System party used for walk-in payment records when sales doc has null party_id.
  static const String walkInPartyId = 'a0000000-0000-4000-8000-000000000001';

  static const walkInCustomerLabel = 'Walk-in Customer';
}
