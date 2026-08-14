import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_select_spinner_dialog.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Opens a select-spinner style dialog to pick a party.
Future<PartyModel?> showMobilePartyPickerSheet(
  BuildContext context, {
  PartyTypeFilter? typeFilter,
  String title = 'Select party',
}) {
  return showMobileSelectSpinnerDialog<PartyModel>(
    context: context,
    builder: (context) => MobilePartyPickerSheet(
      title: title,
      typeFilter: typeFilter,
    ),
  );
}

class MobilePartyPickerSheet extends ConsumerStatefulWidget {
  const MobilePartyPickerSheet({
    required this.title,
    super.key,
    this.typeFilter,
  });

  final String title;
  final PartyTypeFilter? typeFilter;

  @override
  ConsumerState<MobilePartyPickerSheet> createState() =>
      _MobilePartyPickerSheetState();
}

class _MobilePartyPickerSheetState extends ConsumerState<MobilePartyPickerSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final partiesAsync = ref.watch(partyPickerListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MobileSelectSpinnerHeader(
          title: widget.title,
          onClose: () => Navigator.of(context).pop(),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: MobileSearchField(
            hint: 'Search parties',
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Expanded(
          child: partiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => MobileEmptyState(
              title: 'Could not load parties',
              message: error.toString(),
              icon: Icons.error_outline_rounded,
            ),
            data: (parties) {
              final filtered = parties.where((party) {
                if (widget.typeFilter != null &&
                    !widget.typeFilter!.matches(party.partyType)) {
                  return false;
                }
                final q = _query.trim().toLowerCase();
                if (q.isEmpty) return true;
                return party.name.toLowerCase().contains(q) ||
                    party.phone.contains(q);
              }).toList();

              if (filtered.isEmpty) {
                return const MobileEmptyState(
                  title: 'No parties found',
                  message: 'Try a different search.',
                  icon: Icons.people_outline_rounded,
                );
              }

              return ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: filtered.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final party = filtered[index];
                  final phone = party.phone.trim();
                  return ListTile(
                    title: Text(party.name),
                    subtitle: phone.isEmpty ? null : Text(phone),
                    onTap: () => Navigator.of(context).pop(party),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
