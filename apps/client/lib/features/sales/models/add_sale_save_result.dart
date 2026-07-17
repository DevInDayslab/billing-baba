class AddSaleSaveResult {
  const AddSaleSaveResult({
    this.error,
    this.earnedLoyaltyPoints = 0,
    this.pointsAvailable = 0,
  });

  final String? error;
  final int earnedLoyaltyPoints;
  final double pointsAvailable;

  bool get isSuccess => error == null;
  bool get hasLoyaltyEarned => earnedLoyaltyPoints > 0;
}
