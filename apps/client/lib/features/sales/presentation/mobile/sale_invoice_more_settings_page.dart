import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_settings_detail_page.dart';
import 'package:billing_baba/core/widgets/mobile/mobile_settings_tiles.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/sale_invoice_settings_subpages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Vyapar-style Sale Invoice "More Settings" screen (mobile only).
class MobileSaleInvoiceMoreSettingsPage extends ConsumerWidget {
  const MobileSaleInvoiceMoreSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return settingsAsync.when(
      loading: () => const MobileSettingsDetailPage(
        title: 'More Settings',
        isLoading: true,
        body: SizedBox.shrink(),
      ),
      error: (error, _) => MobileSettingsDetailPage(
        title: 'More Settings',
        errorMessage: 'Failed to load sale invoice settings',
        onRetry: () => ref.invalidate(saleInvoiceSettingsProvider),
        body: const SizedBox.shrink(),
      ),
      data: (settings) => MobileSettingsDetailPage(
        title: 'More Settings',
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        body: _SaleInvoiceSettingsBody(settings: settings),
      ),
    );
  }
}

class _SaleInvoiceSettingsBody extends ConsumerWidget {
  const _SaleInvoiceSettingsBody({required this.settings});

  final SaleInvoiceSettings settings;

  Future<void> _update(
    WidgetRef ref,
    SaleInvoiceSettings Function(SaleInvoiceSettings) updater,
  ) {
    return ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(updater);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businesses = ref.watch(businessListProvider).asData?.value ?? [];
    final currentBusiness = ref.watch(currentBusinessProvider);
    final selectedFirm = _resolveFirm(businesses, settings, currentBusiness?.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSection(
          title: 'Transaction Header',
          children: [
            SwitchTile(
              title: 'Invoice/Bill Number',
              value: settings.invoiceBillNumberEnabled,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(invoiceBillNumberEnabled: value),
              ),
            ),
            SwitchTile(
              title: 'Cash Sale by default',
              value: settings.cashSaleByDefault,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(cashSaleByDefault: value),
              ),
            ),
            SwitchTile(
              title: 'Billing name of Parties',
              value: settings.billingNameOfParties,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(billingNameOfParties: value),
              ),
            ),
            SwitchTile(
              title: 'PO Details (Customer)',
              value: settings.poDetailsForCustomer,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(poDetailsForCustomer: value),
              ),
            ),
            SwitchTile(
              title: 'Add Time on Transactions',
              value: settings.addTimeOnTransactions,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(addTimeOnTransactions: value),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Items Table',
          children: [
            SwitchTile(
              title: 'Allow Inclusive/Exclusive Tax',
              value: settings.allowInclusiveExclusiveTax,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(allowInclusiveExclusiveTax: value),
              ),
            ),
            SwitchTile(
              title: 'Display Purchase Price',
              value: settings.displayPurchasePrice,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(displayPurchasePrice: value),
              ),
            ),
            SwitchTile(
              title: 'Show Last 5 Sale Price',
              value: settings.showLast5SalePrice,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(showLast5SalePrice: value),
              ),
            ),
            SwitchTile(
              title: 'Free Item Quantity',
              value: settings.freeItemQuantity,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(freeItemQuantity: value),
              ),
            ),
            SettingsCountTile(
              title: 'Count',
              value: settings.itemsTableCount,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(itemsTableCount: value),
              ),
            ),
            SwitchTile(
              title: 'Barcode Scanning for Items',
              value: settings.barcodeScanningForItems,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(barcodeScanningForItems: value),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Taxes, Discount & Total',
          children: [
            SwitchTile(
              title: 'Transaction-wise Tax',
              value: settings.transactionWiseTax,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(transactionWiseTax: value),
              ),
            ),
            SwitchTile(
              title: 'Transaction-wise Discount',
              value: settings.transactionWiseDiscount,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(transactionWiseDiscount: value),
              ),
            ),
            SwitchTile(
              title: 'Round Off Transaction Amount',
              value: settings.roundOffTransactionAmount,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(roundOffTransactionAmount: value),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'More Transaction Features',
          children: [
            DropdownTile<SaleInvoiceShareFormat>(
              title: 'Share Transaction As',
              value: settings.shareTransactionAs,
              options: SaleInvoiceShareFormat.values,
              labelBuilder: (option) => option.label,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(shareTransactionAs: value),
              ),
            ),
            SettingsTile(
              title: 'Passcode for Edit/Delete',
              value: settings.passcodeForEditDeleteEnabled
                  ? 'Enabled'
                  : 'Disabled',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SaleInvoicePasscodeSettingsPage(),
                ),
              ),
            ),
            SwitchTile(
              title: 'Discount During Payment',
              value: settings.discountDuringPayment,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(discountDuringPayment: value),
              ),
            ),
            SwitchTile(
              title: 'Link Payments to Invoices',
              value: settings.linkPaymentsToInvoices,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(linkPaymentsToInvoices: value),
              ),
            ),
            SwitchTile(
              title: 'Due Dates & Payment Terms',
              value: settings.dueDatesAndPaymentTerms,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(dueDatesAndPaymentTerms: value),
              ),
            ),
            SwitchTile(
              title: 'Enable Invoice Preview',
              value: settings.enableInvoicePreview,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(enableInvoicePreview: value),
              ),
            ),
            SwitchTile(
              title: 'Terms & Conditions',
              value: settings.termsAndConditionsEnabled,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(termsAndConditionsEnabled: value),
              ),
            ),
            SettingsTile(
              title: 'Set Terms & Conditions',
              subtitle: settings.termsAndConditionsText,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SaleInvoiceTermsSettingsPage(),
                ),
              ),
            ),
            SettingsTile(
              title: 'Additional Fields',
              value: settings.additionalFieldsEnabled ? 'On' : 'Off',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const SaleInvoiceAdditionalFieldsPage(),
                ),
              ),
            ),
            SwitchTile(
              title: 'Transportation Details',
              value: settings.transportationDetailsEnabled,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(transportationDetailsEnabled: value),
              ),
            ),
            SwitchTile(
              title: 'Additional Charges',
              value: settings.additionalChargesEnabled,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(additionalChargesEnabled: value),
              ),
            ),
            SwitchTile(
              title: 'Show Profit while making Sale Invoice',
              value: settings.showProfitOnSaleInvoice,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(showProfitOnSaleInvoice: value),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'GST',
          children: [
            SwitchTile(
              title: 'Reverse Charge',
              value: settings.reverseCharge,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(reverseCharge: value),
              ),
            ),
            DropdownTile<String>(
              title: 'State of Supply',
              value: settings.stateOfSupply,
              options: SaleDropdownOptions.indianStates,
              labelBuilder: (option) => option,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(stateOfSupply: value),
              ),
            ),
            SwitchTile(
              title: 'E-Way Bill No.',
              value: settings.eWayBillNumberEnabled,
              onChanged: (value) => _update(
                ref,
                (s) => s.copyWith(eWayBillNumberEnabled: value),
              ),
            ),
          ],
        ),
        SettingsSection(
          title: 'Transaction Prefixes',
          children: [
            DropdownTile<String>(
              title: 'Firm',
              value: selectedFirm.name,
              options: businesses.isEmpty
                  ? [selectedFirm.name]
                  : businesses.map((b) => b.name).toList(),
              labelBuilder: (option) => option,
              onChanged: (name) {
                final firm = businesses.firstWhere(
                  (b) => b.name == name,
                  orElse: () => selectedFirm,
                );
                unawaited(
                  _update(
                    ref,
                    (s) => s.copyWith(selectedFirmId: firm.id),
                  ),
                );
              },
            ),
            for (final type in SaleTransactionPrefixType.values)
              SettingsPrefixTile(
                title: type.label,
                value: settings.prefixFor(type),
                onChanged: (prefix) => _update(
                  ref,
                  (s) => s.copyWith(
                    transactionPrefixes: {
                      ...s.transactionPrefixes,
                      type: prefix,
                    },
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  BusinessModel _resolveFirm(
    List<BusinessModel> businesses,
    SaleInvoiceSettings settings,
    String? currentBusinessId,
  ) {
    if (businesses.isEmpty) {
      return BusinessModel(
        id: currentBusinessId ?? settings.selectedFirmId ?? 'default',
        name: 'My Business',
        syncStatus: SyncStatus.off,
      );
    }

    final selectedId = settings.selectedFirmId ?? currentBusinessId;
    return businesses.firstWhere(
      (b) => b.id == selectedId,
      orElse: () => businesses.first,
    );
  }
}
