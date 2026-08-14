/// Locally stored device trust credential for OTP-less re-login.
class DeviceTrustCredential {
  const DeviceTrustCredential({
    required this.token,
    required this.phone,
    required this.expiresAt,
  });

  final String token;
  final String phone;
  final DateTime expiresAt;
}
