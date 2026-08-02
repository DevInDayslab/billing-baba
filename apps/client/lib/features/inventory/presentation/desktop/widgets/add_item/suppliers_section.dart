import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);

bool _isSupplierParty(PartyModel party) {
  final type = party.partyType.toLowerCase();
  return type == 'supplier' || type == 'both';
}

/// Suppliers tab — attach supplier parties to a product (local form state).
class SuppliersSection extends ConsumerWidget {
  const SuppliersSection({
    required this.selectedPartyIds,
    required this.onChanged,
    super.key,
  });

  final List<String> selectedPartyIds;
  final ValueChanged<List<String>> onChanged;

  Future<void> _openPicker(BuildContext context, WidgetRef ref) async {
    final partiesAsync = ref.read(partyPickerListProvider);
    List<PartyModel> parties;
    try {
      parties =
          partiesAsync.value ?? await ref.read(partyPickerListProvider.future);
    } on Object {
      parties = ref.read(partiesListProvider);
    }

    if (!context.mounted) return;
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => _SupplierPartiesPickerDialog(
        parties: parties,
        initialSelection: selectedPartyIds,
      ),
    );
    if (picked != null) onChanged(picked);
  }

  Future<void> _addParty(BuildContext context, WidgetRef ref) async {
    final result = await showAddPartyDialog(context);
    if (result == null || !context.mounted) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partyListProvider);

    var match = ref
        .read(partiesListProvider)
        .where((party) => party.name == result.partyName)
        .firstOrNull;

    if (match == null) {
      try {
        final pickerParties = await ref.read(partyPickerListProvider.future);
        match = pickerParties
            .where((party) => party.name == result.partyName)
            .firstOrNull;
      } on Object {
        // Best-effort resolve after create.
      }
    }

    if (match == null || !context.mounted) return;
    if (selectedPartyIds.contains(match.id)) return;
    onChanged([...selectedPartyIds, match.id]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parties = ref.watch(partiesListProvider);
    final partiesById = {for (final party in parties) party.id: party};

    // Fall back to picker cache if list is empty/stale.
    final pickerParties = ref.watch(partyPickerListProvider).value ?? const [];
    for (final party in pickerParties) {
      partiesById.putIfAbsent(party.id, () => party);
    }

    final selectedParties = selectedPartyIds
        .map((id) => partiesById[id])
        .whereType<PartyModel>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (selectedParties.isEmpty)
          _EmptyState(
            onAddSupplier: () => _openPicker(context, ref),
            onAddParty: () => _addParty(context, ref),
          )
        else ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final party in selectedParties)
                InputChip(
                  label: Text(party.name),
                  avatar: Icon(
                    Icons.local_shipping_outlined,
                    size: 16,
                    color: Colors.grey.shade700,
                  ),
                  onDeleted: () => onChanged(
                    selectedPartyIds.where((id) => id != party.id).toList(),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: () => _openPicker(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add supplier'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: _cardBorder),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _addParty(context, ref),
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Add Party'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Suppliers are linked to this product for purchase workflows.',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.onAddSupplier,
    required this.onAddParty,
  });

  final VoidCallback onAddSupplier;
  final VoidCallback onAddParty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_shipping_outlined,
            size: 40,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No suppliers yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Select existing supplier parties or create a new party',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: onAddSupplier,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add supplier'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: _cardBorder),
                ),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: onAddParty,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Add Party'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupplierPartiesPickerDialog extends ConsumerStatefulWidget {
  const _SupplierPartiesPickerDialog({
    required this.parties,
    required this.initialSelection,
  });

  final List<PartyModel> parties;
  final List<String> initialSelection;

  @override
  ConsumerState<_SupplierPartiesPickerDialog> createState() =>
      _SupplierPartiesPickerDialogState();
}

class _SupplierPartiesPickerDialogState
    extends ConsumerState<_SupplierPartiesPickerDialog> {
  late final TextEditingController _searchController;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _selected = widget.initialSelection.toSet();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PartyModel> get _candidates {
    final query = _searchController.text.trim().toLowerCase();
    final selectedIds = _selected;
    // Show supplier/both parties, plus any already-selected (even if customer).
    final base = widget.parties.where((party) {
      if (selectedIds.contains(party.id)) return true;
      return _isSupplierParty(party);
    }).toList();

    if (query.isEmpty) return base;
    return base.where((party) {
      final haystack = [
        party.name,
        party.phone,
        party.gstin,
        party.email,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  Future<void> _createParty() async {
    final result = await showAddPartyDialog(context);
    if (result == null || !mounted) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partyListProvider);

    var match = ref
        .read(partiesListProvider)
        .where((party) => party.name == result.partyName)
        .firstOrNull;

    if (match == null) {
      try {
        final pickerParties = await ref.read(partyPickerListProvider.future);
        match = pickerParties
            .where((party) => party.name == result.partyName)
            .firstOrNull;
      } on Object {
        // Best-effort.
      }
    }

    if (match == null || !mounted) return;
    setState(() => _selected.add(match!.id));
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _candidates;

    return AlertDialog(
      title: const Text('Select suppliers'),
      content: SizedBox(
        width: 480,
        height: 460,
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: buildFormControlDecoration(
                hint: 'Search suppliers...',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _createParty,
                icon: const Icon(Icons.person_add_alt_1_outlined, size: 16),
                label: const Text('Add Party'),
              ),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.trim().isEmpty
                            ? 'No supplier parties found'
                            : 'No matching suppliers',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final party = filtered[index];
                        final checked = _selected.contains(party.id);
                        return CheckboxListTile(
                          value: checked,
                          title: Text(party.name),
                          subtitle: Text(
                            [
                              party.partyTypeLabel,
                              if (party.phone.trim().isNotEmpty) party.phone,
                            ].join(' · '),
                          ),
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selected.add(party.id);
                              } else {
                                _selected.remove(party.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selected.toList()),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
