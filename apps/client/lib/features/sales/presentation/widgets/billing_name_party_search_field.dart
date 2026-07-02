import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_search_field.dart';
import 'package:flutter/material.dart';

class BillingNamePartySearchField extends PartySearchField {
  const BillingNamePartySearchField({
    required super.value,
    required super.onSelected,
    super.onPartyCreated,
    super.hasError,
    super.emptyPlaceholder,
    super.errorMessage,
    super.key,
  });
}
