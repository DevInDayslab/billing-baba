import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { unauthenticated, otpSent, authenticated }

class AuthState {
  const AuthState({
    this.status = AuthStatus.unauthenticated,
    this.phone = '',
    this.isLoading = false,
    this.error,
  });

  final AuthStatus status;
  final String phone;
  final bool isLoading;
  final String? error;

  AuthState copyWith({
    AuthStatus? status,
    String? phone,
    bool? isLoading,
    String? error,
  }) =>
      AuthState(
        status: status ?? this.status,
        phone: phone ?? this.phone,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class AuthNotifier extends Notifier<AuthState> {
  static const _defaultOtp = '123456';

  @override
  AuthState build() => const AuthState();

  Future<void> sendOtp(String phone) async {
    state = state.copyWith(isLoading: true, error: null);
    // Simulate network delay
    await Future<void>.delayed(const Duration(milliseconds: 800));
    state = state.copyWith(
      isLoading: false,
      status: AuthStatus.otpSent,
      phone: phone,
    );
  }

  Future<bool> verifyOtp(String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    if (otp == _defaultOtp) {
      state = state.copyWith(
        isLoading: false,
        status: AuthStatus.authenticated,
      );
      return true;
    }

    state = state.copyWith(
      isLoading: false,
      error: 'Incorrect OTP. Please try again.',
    );
    return false;
  }

  void resendOtp() {
    state = state.copyWith(status: AuthStatus.otpSent, error: null);
  }

  void logout() {
    state = const AuthState();
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
