import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_session_service.dart';
import 'package:billing_baba/features/sales/models/dto/pos_session_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_session_provider.g.dart';

class PosSessionState {
  const PosSessionState({
    this.isTerminalOpen = false,
    this.backendSession,
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isTerminalOpen;
  final PosSessionDto? backendSession;
  final bool isLoading;
  final String? errorMessage;

  bool get hasActiveBackendSession =>
      backendSession != null && backendSession!.isOpen;

  bool get hasActiveSession => hasActiveBackendSession;

  PosSessionState copyWith({
    bool? isTerminalOpen,
    PosSessionDto? backendSession,
    bool clearBackendSession = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PosSessionState(
      isTerminalOpen: isTerminalOpen ?? this.isTerminalOpen,
      backendSession: clearBackendSession
          ? null
          : (backendSession ?? this.backendSession),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// POS terminal UI state plus backend cash-drawer session.
@Riverpod(keepAlive: true)
class PosSession extends _$PosSession {
  @override
  PosSessionState build() => const PosSessionState();

  Future<void> openTerminal() async {
    ref.read(posCartProvider.notifier).clearCart();
    state = state.copyWith(
      isTerminalOpen: true,
      isLoading: true,
      clearError: true,
    );

    try {
      final sessionService = await ref.read(posSessionServiceProvider.future);
      final session = await sessionService.getOrOpenSession();
      state = state.copyWith(
        backendSession: session,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: OfflineUiMessages.messageFor(error),
      );
    }
  }

  Future<void> closeTerminal({double closingCash = 0}) async {
    final session = state.backendSession;
    if (session != null && session.isOpen) {
      try {
        final sessionService = await ref.read(posSessionServiceProvider.future);
        await sessionService.closeSession(
          sessionId: session.id,
          closingCash: closingCash,
        );
      } catch (_) {
        // Terminal can still close locally if backend close fails.
      }
    }

    state = const PosSessionState();
  }
}
