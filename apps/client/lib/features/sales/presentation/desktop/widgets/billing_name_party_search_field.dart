import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_search_field.dart';

class BillingNamePartySearchField extends PartySearchField {
  const BillingNamePartySearchField({
    required super.value,
    required super.onSelected,
    super.onPartySelected,
    super.onPartySelectedWithId,
    super.onPartyCreated,
    super.selectedPartyId,
    super.partyTypeFilter,
    super.hasError,
    super.emptyPlaceholder,
    super.errorMessage,
    super.key,
  });
}
