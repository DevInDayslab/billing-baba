import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mock session state until auth backend integration.
class AuthSession {
  const AuthSession({
    required this.phone,
    this.isLoggedIn = true,
  });

  final String phone;
  final bool isLoggedIn;
}

final authSessionProvider = Provider<AuthSession>(
  (ref) => const AuthSession(phone: '+91 98765 43210'),
);
