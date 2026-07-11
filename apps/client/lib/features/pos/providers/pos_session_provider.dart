import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pos_session_provider.g.dart';

/// Whether the full-screen POS terminal is open (vs the landing list).
@Riverpod(keepAlive: true)
class PosSession extends _$PosSession {
  @override
  bool build() => false;

  void openTerminal() {
    ref.read(posCartProvider.notifier).clearCart();
    state = true;
  }

  void closeTerminal() => state = false;
}
