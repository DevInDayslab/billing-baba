import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/theme/list_panel_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/sales/application/sale_invoice_settings_provider.dart';
import 'package:billing_baba/features/sales/models/sale_invoice_settings.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/sale_invoice_settings_subpages.dart';
import 'package:billing_baba/features/settings/models/transaction_settings_info_catalog.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/general_settings_form_widgets.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/settings_info_dialog.dart';
import 'package:billing_baba/features/sales/models/transaction_form_extras.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/transaction_settings_editors.dart';
import 'package:billing_baba/features/settings/presentation/desktop/widgets/transaction_settings_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef _SaleSettingsUpdater = SaleInvoiceSettings Function(SaleInvoiceSettings s);

/// Settings → Transaction (Vyapar-style, three columns).
class DesktopTransactionSettingsScreen extends ConsumerWidget {
  const DesktopTransactionSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(saleInvoiceSettingsProvider);

    return settingsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Text(
          'Could not load transaction settings: $error',
          style: AppTypography.inter(
            fontSize: AppTypography.bodyMediumSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
      data: (settings) {
        Future<void> patch(_SaleSettingsUpdater update) {
          return ref.read(saleInvoiceSettingsProvider.notifier).updateSettings(
            update,
            silent: false,
          );
        }

        final businesses = ref.watch(businessListProvider).asData?.value ?? [];
        final currentId = ref.watch(currentBusinessProvider)?.id ?? '';
        final selectedFirmId = settings.selectedFirmId ?? currentId;
        final firmName = _firmName(businesses, selectedFirmId, settings);

        final col1 = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GeneralSettingsSectionCard(
              title: 'Transaction Header',
              children: [
                TransactionSettingsCheckboxRow(
                  label: 'Invoice/Bill No.',
                  value: settings.invoiceBillNumberEnabled,
                  infoKey: TransactionSettingsInfoKey.invoiceBillNo,
                  onChanged: (v) {
                    final enabled = v ?? false;
                    patch(
                      (s) => s.copyWith(
                        invoiceBillNumberEnabled: enabled,
                        manualInvoiceNumberEnabled: enabled
                            ? s.manualInvoiceNumberEnabled
                            : false,
                      ),
                    );
                  },
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Allow editing sale invoice number',
                  value: settings.manualInvoiceNumberEnabled,
                  infoKey: TransactionSettingsInfoKey.manualInvoiceNumber,
                  onChanged: settings.invoiceBillNumberEnabled
                      ? (v) => patch(
                          (s) => s.copyWith(
                            manualInvoiceNumberEnabled: v ?? false,
                          ),
                        )
                      : null,
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Add Time on Transactions',
                  value: settings.addTimeOnTransactions,
                  infoKey: TransactionSettingsInfoKey.addTimeOnTransactions,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(addTimeOnTransactions: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Print Time on Invoices',
                  value: settings.printTimeOnInvoices,
                  infoKey: TransactionSettingsInfoKey.printTimeOnInvoices,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(printTimeOnInvoices: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Cash Sale by default',
                  value: settings.cashSaleByDefault,
                  infoKey: TransactionSettingsInfoKey.cashSaleByDefault,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(cashSaleByDefault: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Billing Name of Parties',
                  value: settings.billingNameOfParties,
                  infoKey: TransactionSettingsInfoKey.billingNameOfParties,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(billingNameOfParties: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Customers P.O. Details on Transactions',
                  value: settings.poDetailsForCustomer,
                  infoKey: TransactionSettingsInfoKey.customersPoDetails,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(poDetailsForCustomer: v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GeneralSettingsSectionCard(
              title: 'More Transaction Features',
              children: [
                TransactionSettingsCheckboxRow(
                  label: 'E-way bill no',
                  value: settings.eWayBillNumberEnabled,
                  infoKey: TransactionSettingsInfoKey.eWayBillNo,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(eWayBillNumberEnabled: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Quick Entry',
                  value: settings.quickEntry,
                  infoKey: TransactionSettingsInfoKey.quickEntry,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(quickEntry: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Do not Show Invoice Preview',
                  value: !settings.enableInvoicePreview,
                  infoKey: TransactionSettingsInfoKey.doNotShowInvoicePreview,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(enableInvoicePreview: !(v ?? false)),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Repeat Invoices',
                  value: settings.repeatInvoices,
                  infoKey: TransactionSettingsInfoKey.repeatInvoices,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(repeatInvoices: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Enable Passcode for transaction edit/delete',
                  value: settings.passcodeForEditDeleteEnabled,
                  infoKey: TransactionSettingsInfoKey.passcodeEditDelete,
                  onChanged: (v) async {
                    final enabled = v ?? false;
                    await patch(
                      (s) => s.copyWith(passcodeForEditDeleteEnabled: enabled),
                    );
                    if (enabled && context.mounted) {
                      await _openSettingsDialog(
                        context,
                        const SaleInvoicePasscodeSettingsPage(),
                      );
                    }
                  },
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Discount During Payments',
                  value: settings.discountDuringPayment,
                  infoKey: TransactionSettingsInfoKey.discountDuringPayments,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(discountDuringPayment: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Link Payments to Invoices',
                  value: settings.linkPaymentsToInvoices,
                  infoKey: TransactionSettingsInfoKey.linkPaymentsToInvoices,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(linkPaymentsToInvoices: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Due Dates and Payment Terms',
                  value: settings.dueDatesAndPaymentTerms,
                  infoKey: TransactionSettingsInfoKey.dueDatesPaymentTerms,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(dueDatesAndPaymentTerms: v ?? false),
                  ),
                ),
                if (settings.dueDatesAndPaymentTerms)
                  TransactionSettingsLinkButton(
                    label: 'Set Payment Terms',
                    onTap: () => showPaymentTermsEditor(
                      context: context,
                      initial: settings.formExtras.paymentTerms,
                      onSave: (terms) => patch(
                        (s) => s.copyWith(
                          formExtras: s.formExtras.copyWith(paymentTerms: terms),
                        ),
                      ),
                    ),
                  ),
                TransactionSettingsCheckboxRow(
                  label: 'Show Profit while making Sale Invoice',
                  value: settings.showProfitOnSaleInvoice,
                  infoKey: TransactionSettingsInfoKey.showProfitOnSaleInvoice,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(showProfitOnSaleInvoice: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: "Show 'Wholesale Price' toggle on Invoice",
                  value: settings.wholesalePriceToggleOnInvoice,
                  infoKey: TransactionSettingsInfoKey.wholesalePriceToggle,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(wholesalePriceToggleOnInvoice: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Terms and Conditions',
                  value: settings.termsAndConditionsEnabled,
                  infoKey: TransactionSettingsInfoKey.termsAndConditions,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(termsAndConditionsEnabled: v ?? false),
                  ),
                ),
                if (settings.termsAndConditionsEnabled)
                  TransactionSettingsLinkButton(
                    label: 'Set Terms and Conditions',
                    onTap: () => _openSettingsDialog(
                      context,
                      const SaleInvoiceTermsSettingsPage(),
                    ),
                  ),
                TransactionSettingsLinkButton(
                  label: 'Additional Fields >',
                  onTap: () => _openSettingsDialog(
                    context,
                    const SaleInvoiceAdditionalFieldsPage(),
                  ),
                ),
                TransactionSettingsLinkButton(
                  label: 'Transportation Details >',
                  onTap: () => showTransportationEditor(
                    context: context,
                    initial: settings.formExtras.transportFields,
                    onSave: (fields) => patch(
                      (s) => s.copyWith(
                        formExtras: s.formExtras.copyWith(
                          transportFields: fields,
                        ),
                      ),
                    ),
                  ),
                ),
                TransactionSettingsLinkButton(
                  label: 'Additional Charges >',
                  onTap: () => showAdditionalChargesEditor(
                    context: context,
                    ref: ref,
                    enabled: settings.additionalChargesEnabled,
                    charges: settings.formExtras.additionalCharges,
                    onSave: (enabled, charges) => patch(
                      (s) => s.copyWith(
                        additionalChargesEnabled: enabled,
                        formExtras: s.formExtras.copyWith(
                          additionalCharges: charges,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );

        final col2 = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GeneralSettingsSectionCard(
              title: 'Items Table',
              children: [
                TransactionSettingsCheckboxRow(
                  label: 'Inclusive/Exclusive Tax on Rate(Price/Unit)',
                  value: settings.allowInclusiveExclusiveTax,
                  infoKey: TransactionSettingsInfoKey.inclusiveExclusiveTax,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(allowInclusiveExclusiveTax: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Display Purchase Price of Items',
                  value: settings.displayPurchasePrice,
                  infoKey: TransactionSettingsInfoKey.displayPurchasePrice,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(displayPurchasePrice: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Show last 5 Sale Price of Items',
                  value: settings.showLast5SalePrice,
                  infoKey: TransactionSettingsInfoKey.showLast5SalePrice,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(showLast5SalePrice: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Show last 5 Purchase Price of Items',
                  value: settings.showLast5PurchasePrice,
                  infoKey: TransactionSettingsInfoKey.showLast5PurchasePrice,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(showLast5PurchasePrice: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Free Item Quantity',
                  value: settings.freeItemQuantity,
                  infoKey: TransactionSettingsInfoKey.freeItemQuantity,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(freeItemQuantity: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: settings.countColumnLabel,
                  value: settings.countColumnEnabled,
                  infoKey: TransactionSettingsInfoKey.count,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(countColumnEnabled: v ?? false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GeneralSettingsSectionCard(
              title: 'Transaction Prefixes',
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    children: [
                      Text(
                        'Firm',
                        style: AppTypography.inter(
                          fontSize: AppTypography.bodySmallSize,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedFirmId.isEmpty ? null : selectedFirmId,
                          isExpanded: true,
                          decoration: _dropdownDecoration(),
                          items: [
                            for (final b in businesses)
                              DropdownMenuItem(value: b.id, child: Text(b.name)),
                            if (businesses.isEmpty)
                              DropdownMenuItem(
                                value: selectedFirmId,
                                child: Text(firmName),
                              ),
                          ],
                          onChanged: (id) {
                            if (id == null) return;
                            patch((s) => s.copyWith(selectedFirmId: id));
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columnWidth =
                        (constraints.maxWidth - AppSpacing.sm) / 2;
                    return Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        for (final type in transactionSettingsPrefixTypes)
                          SizedBox(
                            width: columnWidth,
                            child: TransactionPrefixField(
                              type: type,
                              selected: settings.prefixFor(type),
                              firmName: firmName,
                              customPrefixes: settings.formExtras.customPrefixes,
                              onSelected: (value) => patch(
                                (s) => s.copyWith(
                                  transactionPrefixes: {
                                    ...s.transactionPrefixes,
                                    type: value,
                                  },
                                ),
                              ),
                              onAddCustom: (value) => patch(
                                (s) => s.copyWith(
                                  formExtras: s.formExtras.copyWith(
                                    customPrefixes: [
                                      ...s.formExtras.customPrefixes,
                                      if (!s.formExtras.customPrefixes.contains(
                                        value,
                                      ))
                                        value,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        );

        final col3 = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GeneralSettingsSectionCard(
              title: 'Taxes, Discount & Totals',
              children: [
                TransactionSettingsCheckboxRow(
                  label: 'Transaction wise Tax',
                  value: settings.transactionWiseTax,
                  infoKey: TransactionSettingsInfoKey.transactionWiseTax,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(transactionWiseTax: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Transaction wise Discount',
                  value: settings.transactionWiseDiscount,
                  infoKey: TransactionSettingsInfoKey.transactionWiseDiscount,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(transactionWiseDiscount: v ?? false),
                  ),
                ),
                TransactionSettingsCheckboxRow(
                  label: 'Round Off Total',
                  value: settings.roundOffTransactionAmount,
                  infoKey: TransactionSettingsInfoKey.roundOffTotal,
                  onChanged: (v) => patch(
                    (s) => s.copyWith(roundOffTransactionAmount: v ?? false),
                  ),
                ),
                if (settings.roundOffTransactionAmount)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.xl),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<RoundOffMode>(
                            value: settings.formExtras.roundOffMode,
                            decoration: _dropdownDecoration(),
                            items: [
                              for (final mode in RoundOffMode.valuesInOrder)
                                DropdownMenuItem(
                                  value: mode,
                                  child: Text(mode.label),
                                ),
                            ],
                            onChanged: (mode) {
                              if (mode == null) return;
                              patch(
                                (s) => s.copyWith(
                                  formExtras: s.formExtras.copyWith(
                                    roundOffMode: mode,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                          ),
                          child: Text(
                            'To',
                            style: AppTypography.inter(
                              fontSize: AppTypography.bodySmallSize,
                            ),
                          ),
                        ),
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: roundOffTargetValues.contains(
                              settings.roundOffToValue,
                            )
                                ? settings.roundOffToValue
                                : roundOffTargetValues.first,
                            decoration: _dropdownDecoration(),
                            items: [
                              for (final n in roundOffTargetValues)
                                DropdownMenuItem(value: n, child: Text('$n')),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              patch((s) => s.copyWith(roundOffToValue: v));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            GeneralSettingsSectionCard(
              title: 'Billing Type',
              children: [
                RadioListTile<SaleBillingFormMode>(
                  title: const Text('Lite Sale'),
                  value: SaleBillingFormMode.liteSale,
                  groupValue: settings.billingFormMode,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    if (v == null) return;
                    patch((s) => s.copyWith(billingFormMode: v));
                  },
                ),
                RadioListTile<SaleBillingFormMode>(
                  title: const Text('Full Sale'),
                  value: SaleBillingFormMode.fullSale,
                  groupValue: settings.billingFormMode,
                  activeColor: AppColors.primary,
                  onChanged: (v) {
                    if (v == null) return;
                    patch((s) => s.copyWith(billingFormMode: v));
                  },
                ),
              ],
            ),
          ],
        );

        return ColoredBox(
          color: AppColors.background,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 1100;
                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: col1),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: col2),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: col3),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    col1,
                    const SizedBox(height: AppSpacing.md),
                    col2,
                    const SizedBox(height: AppSpacing.md),
                    col3,
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  static String _firmName(
    List<BusinessModel> businesses,
    String selectedId,
    SaleInvoiceSettings settings,
  ) {
    for (final b in businesses) {
      if (b.id == selectedId) return b.name;
    }
    return 'Current firm';
  }

  static InputDecoration _dropdownDecoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: listPanelCardBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
        borderSide: const BorderSide(color: listPanelCardBorder),
      ),
      filled: true,
      fillColor: AppColors.background,
    );
  }

  static Future<void> _openSettingsDialog(BuildContext context, Widget page) {
    return showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
          child: page,
        ),
      ),
    );
  }
}
