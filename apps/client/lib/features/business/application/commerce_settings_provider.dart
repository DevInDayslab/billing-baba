import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/business/data/commerce_settings_remote_data_source.dart';
import 'package:billing_baba/features/business/models/commerce_settings_model.dart';
import 'package:billing_baba/features/pricing/models/price_tier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'commerce_settings_provider.g.dart';

@Riverpod(keepAlive: true)
Future<CommerceSettingsRemoteDataSource> commerceSettingsRemoteDataSource(
  Ref ref,
) async {
  final api = await ref.watch(apiClientProvider.future);
  return CommerceSettingsRemoteDataSource(api.dio);
}

@Riverpod(keepAlive: true)
class CommerceSettings extends _$CommerceSettings {
  @override
  Future<CommerceSettingsModel> build() async {
    final remote = await ref.watch(
      commerceSettingsRemoteDataSourceProvider.future,
    );
    return remote.fetch();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final remote = await ref.read(
        commerceSettingsRemoteDataSourceProvider.future,
      );
      return remote.fetch();
    });
  }

  Future<CommerceSettingsModel> save({
    Map<String, String>? pricingTierLabels,
    double? defaultInvoiceTaxRate,
    bool clearDefaultInvoiceTaxRate = false,
  }) async {
    final remote = await ref.read(
      commerceSettingsRemoteDataSourceProvider.future,
    );
    final current =
        state.value ?? const CommerceSettingsModel(pricingTierLabels: {});
    final updated = await remote.update(
      current.toUpdateJson(
        pricingTierLabels: pricingTierLabels,
        defaultInvoiceTaxRate: defaultInvoiceTaxRate,
        clearDefaultInvoiceTaxRate: clearDefaultInvoiceTaxRate,
      ),
    );
    state = AsyncData(updated);
    return updated;
  }
}

/// Business-scoped display names for pricing tiers (`tier_1` → label).
final pricingTierLabelsProvider = Provider<Map<String, String>>((ref) {
  final settings = ref.watch(commerceSettingsProvider).value;
  if (settings == null || settings.pricingTierLabels.isEmpty) {
    return {
      for (final tier in PriceTier.all)
        PriceTier.toApiTier(tier): PriceTier.labelFor(tier),
    };
  }
  return settings.pricingTierLabels;
});
