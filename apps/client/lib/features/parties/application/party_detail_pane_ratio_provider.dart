import 'package:billing_baba/core/constants/storage_keys.dart';
import 'package:billing_baba/core/providers/storage_service_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'party_detail_pane_ratio_provider.g.dart';

/// Persisted height ratio for the party detail upper pane (header + notes)
/// versus the transactions table on desktop.
@Riverpod(keepAlive: true)
class PartyDetailPaneRatio extends _$PartyDetailPaneRatio {
  static const defaultRatio = 0.42;
  static const minRatio = 0.22;
  static const maxRatio = 0.78;

  @override
  double build() {
    _loadPreference();
    return defaultRatio;
  }

  Future<void> _loadPreference() async {
    final storage = await ref.read(storageServiceProvider.future);
    if (!ref.mounted) return;

    final raw = storage.read(StorageKeys.partyDetailUpperPaneRatio);
    final parsed = double.tryParse(raw ?? '');
    if (parsed != null) {
      state = _clamp(parsed);
    }
  }

  void setRatio(double ratio) {
    final clamped = _clamp(ratio);
    if (state == clamped) return;
    state = clamped;
    _persist(clamped);
  }

  double _clamp(double ratio) => ratio.clamp(minRatio, maxRatio);

  Future<void> _persist(double ratio) async {
    final storage = await ref.read(storageServiceProvider.future);
    await storage.write(
      StorageKeys.partyDetailUpperPaneRatio,
      ratio.toString(),
    );
  }
}
