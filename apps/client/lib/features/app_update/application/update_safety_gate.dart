import 'package:billing_baba/core/sync/providers/sync_providers.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/sale_screen/application/sale_screen_tabs_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UpdateSafetyResult {
  const UpdateSafetyResult({
    this.hardBlocks = const [],
    this.softBlocks = const [],
  });

  final List<String> hardBlocks;
  final List<String> softBlocks;

  bool get hasHardBlock => hardBlocks.isNotEmpty;
  bool get hasSoftBlock => softBlocks.isNotEmpty;
}

final updateSafetyGateProvider = Provider<UpdateSafetyGate>((ref) {
  return UpdateSafetyGate(ref);
});

class UpdateSafetyGate {
  UpdateSafetyGate(this._ref);

  final Ref _ref;

  Future<UpdateSafetyResult> evaluate() async {
    final hardBlocks = <String>[];
    final tabs = _ref.read(saleScreenTabsProvider).tabs;
    for (final tab in tabs) {
      final cart = _ref.read(posCartProvider(sessionKey: tab.sessionKey));
      final hasItems = cart.items.isNotEmpty;
      final hasPayments = cart.payments.any((payment) => payment.amount > 0);
      if (hasItems || hasPayments) {
        hardBlocks.add(
          'Finish or hold the bill in tab ${tab.posNumber}',
        );
      }
    }

    final softBlocks = <String>[];
    final pendingCount = await _ref.read(syncQueueProvider).pendingCount();
    if (pendingCount > 0) {
      softBlocks.add(
        '$pendingCount item${pendingCount == 1 ? '' : 's'} still syncing',
      );
    }

    return UpdateSafetyResult(
      hardBlocks: hardBlocks,
      softBlocks: softBlocks,
    );
  }
}
