import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_form_widgets.dart';
import 'package:billing_baba/features/sales/presentation/mobile/widgets/mobile_sale_party_picker_field.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_document_visibility.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_party_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Party search + optional billing/phone/address/GSTIN/email fields.
class MobileDocumentPartySection extends StatelessWidget {
  const MobileDocumentPartySection({
    required this.visibility,
    super.key,
    this.partyController,
    this.selectedPartyId,
    this.partyHasError = false,
    this.partyTypeFilter = PartyTypeFilter.customer,
    this.partyLabel = 'Customer',
    this.partyValue = '',
    this.onSearchChanged,
    this.onPartySelected,
    this.onPickParty,
    this.useInlinePartySearch = true,
    this.billingNameController,
    this.onBillingNameChanged,
    this.phoneController,
    this.phoneHasError = false,
    this.phoneErrorText,
    this.onPhoneChanged,
    this.billingAddressController,
    this.onBillingAddressChanged,
    this.shippingAddressController,
    this.onShippingAddressChanged,
    this.gstinController,
    this.onGstinChanged,
    this.emailController,
    this.onEmailChanged,
  });

  final MobileDocumentVisibility visibility;
  final TextEditingController? partyController;
  final String? selectedPartyId;
  final bool partyHasError;
  final PartyTypeFilter partyTypeFilter;
  final String partyLabel;
  final String partyValue;
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<PartyModel>? onPartySelected;
  final VoidCallback? onPickParty;
  final bool useInlinePartySearch;
  final TextEditingController? billingNameController;
  final ValueChanged<String>? onBillingNameChanged;
  final TextEditingController? phoneController;
  final bool phoneHasError;
  final String? phoneErrorText;
  final ValueChanged<String>? onPhoneChanged;
  final TextEditingController? billingAddressController;
  final ValueChanged<String>? onBillingAddressChanged;
  final TextEditingController? shippingAddressController;
  final ValueChanged<String>? onShippingAddressChanged;
  final TextEditingController? gstinController;
  final ValueChanged<String>? onGstinChanged;
  final TextEditingController? emailController;
  final ValueChanged<String>? onEmailChanged;

  @override
  Widget build(BuildContext context) {
    if (!visibility.showParty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (useInlinePartySearch &&
            partyController != null &&
            onPartySelected != null &&
            onSearchChanged != null)
          MobileSalePartyPickerField(
            controller: partyController!,
            selectedPartyId: selectedPartyId,
            hasError: partyHasError,
            partyTypeFilter: partyTypeFilter,
            onSearchChanged: onSearchChanged!,
            onPartySelected: onPartySelected!,
          )
        else
          MobileSalePickerField(
            label: partyLabel,
            value: partyValue.isEmpty ? 'Select $partyLabel' : partyValue,
            isPlaceholder: partyValue.isEmpty,
            onTap: onPickParty ?? () {},
          ),
        if (visibility.showBillingName) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Billing Name (Optional)',
            controller: billingNameController,
            hintText: 'Billing Name (Optional)',
            onChanged: onBillingNameChanged,
          ),
        ],
        if (visibility.showPhone) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Phone Number',
            controller: phoneController,
            hintText: 'Phone number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            hasError: phoneHasError,
            errorText: phoneErrorText,
            onChanged: onPhoneChanged,
          ),
        ],
        if (visibility.showBillingAddress) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Billing Address',
            controller: billingAddressController,
            hintText: 'Billing address',
            minLines: 2,
            maxLines: 3,
            onChanged: onBillingAddressChanged,
          ),
        ],
        if (visibility.showShippingAddress) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Shipping Address',
            controller: shippingAddressController,
            hintText: 'Shipping address',
            minLines: 2,
            maxLines: 3,
            onChanged: onShippingAddressChanged,
          ),
        ],
        if (visibility.showGstin) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'GSTIN',
            controller: gstinController,
            hintText: 'GSTIN',
            onChanged: onGstinChanged,
          ),
        ],
        if (visibility.showEmail) ...[
          const SizedBox(height: AppSpacing.lg),
          MobileSaleFormField(
            label: 'Email',
            controller: emailController,
            hintText: 'Email',
            keyboardType: TextInputType.emailAddress,
            onChanged: onEmailChanged,
          ),
        ],
      ],
    );
  }
}

/// Helper to open the shared party select-spinner from any document page.
Future<PartyModel?> pickMobileDocumentParty(
  BuildContext context, {
  PartyTypeFilter typeFilter = PartyTypeFilter.customer,
  String? title,
}) {
  return showMobilePartyPickerSheet(
    context,
    typeFilter: typeFilter,
    title: title ?? 'Select party',
  );
}
