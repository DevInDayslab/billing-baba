import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_sheet.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bottom sheet to pick a party for mobile transaction forms.
Future<PartyModel?> showMobilePartyPickerSheet(
  BuildContext context, {
  PartyTypeFilter? typeFilter,
  String title = 'Select party',
}) {
  return showMobileBottomSheet<PartyModel>(
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

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: AppTypography.inter(
                    fontSize: AppTypography.titleSize,
                    fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MobileSearchField(
              hint: 'Search parties',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Flexible(
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
                      (party.phone?.contains(q) ?? false);
                }).toList();

                if (filtered.isEmpty) {
                  return const MobileEmptyState(
                    title: 'No parties found',
                    message: 'Try a different search.',
                    icon: Icons.people_outline_rounded,
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final party = filtered[index];
                    return ListTile(
                      title: Text(party.name),
                      subtitle: party.phone != null
                          ? Text(party.phone!)
                          : null,
                      onTap: () => Navigator.of(context).pop(party),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
