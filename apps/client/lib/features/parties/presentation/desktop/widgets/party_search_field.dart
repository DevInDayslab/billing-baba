import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_ellipsis_text.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_avatar.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Searchable party picker with "+ Add New Party" action.
class PartySearchField extends ConsumerStatefulWidget {
  const PartySearchField({
    required this.value,
    required this.onSelected,
    this.onPartySelected,
    this.onPartySelectedWithId,
    this.onPartyCreated,
    this.selectedPartyId,
    this.partyTypeFilter = PartyTypeFilter.all,
    this.hasError = false,
    this.emptyPlaceholder = 'Select party',
    this.errorMessage = 'Billing name is required',
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
  final ValueChanged<PartyModel>? onPartySelected;
  final void Function(String partyId, String partyName)? onPartySelectedWithId;
  final ValueChanged<AddPartyResult>? onPartyCreated;
  final String? selectedPartyId;
  final PartyTypeFilter partyTypeFilter;
  final bool hasError;
  final String emptyPlaceholder;
  final String errorMessage;

  @override
  ConsumerState<PartySearchField> createState() => PartySearchFieldState();
}

class PartySearchFieldState extends ConsumerState<PartySearchField> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  String _searchQuery = '';
  String? _lastSelectedPartyId;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  void didUpdateWidget(PartySearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPartyId != null &&
        widget.selectedPartyId != oldWidget.selectedPartyId) {
      _lastSelectedPartyId = widget.selectedPartyId;
    }
    if (widget.value.isEmpty) {
      _lastSelectedPartyId = null;
    }
  }

  void closeMenu() => _removeOverlay();

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _searchQuery = '';
      // Kick off data fetch before showing overlay so data is ready
      // (or already cached) by the time the user sees the list.
      final partiesAsync = ref.read(partyPickerListProvider);
      if (!partiesAsync.hasValue || (partiesAsync.value?.isEmpty ?? true)) {
        // Not cached yet — reading the provider triggers the FutureProvider fetch.
        ref.read(partyPickerListProvider.future).ignore();
      }
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectParty(PartyModel party) {
    _lastSelectedPartyId = party.id;
    _removeOverlay();
    widget.onSelected(party.name);
    widget.onPartySelected?.call(party);
    widget.onPartySelectedWithId?.call(party.id, party.name);
  }

  List<PartyModel> get _filteredParties {
    final parties = ref.watch(partyPickerListProvider).value ?? [];
    final filtered = parties
        .where((party) => widget.partyTypeFilter.matches(party.partyType))
        .toList();

    if (_searchQuery.isEmpty) return filtered;

    final query = _searchQuery.trim().toLowerCase();
    return filtered.where((party) => _partyMatchesQuery(party, query)).toList();
  }

  bool _partyMatchesQuery(PartyModel party, String query) {
    // Split query into words so "Delhi ABC" matches "ABC Traders Delhi"
    final queryWords = query
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    if (queryWords.isEmpty) return true;

    // Combine all searchable fields into one string
    final searchableText = [
      party.name,
      party.additionalField1,
      party.phone,
      party.gstin,
      party.email,
    ].join(' ').toLowerCase();

    // Every query word must be found somewhere in the combined text
    return queryWords.every(searchableText.contains);
  }

  Future<void> _openAddPartyDialog() async {
    _removeOverlay();
    final result = await showAddPartyDialog(context);
    if (!mounted || result == null) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partiesListProvider);

    if (!mounted) return;
    widget.onSelected(result.partyName);

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
        // Picker refresh is best-effort after create.
      }
    }

    if (match != null) {
      _lastSelectedPartyId = match.id;
      widget.onPartySelected?.call(match);
      widget.onPartySelectedWithId?.call(match.id, match.name);
    }
    widget.onPartyCreated?.call(result);
  }

  PartyModel? _resolveSelectedParty() {
    final partyId = widget.selectedPartyId ?? _lastSelectedPartyId;
    if (partyId != null && partyId.isNotEmpty) {
      final fromList = ref
          .read(partiesListProvider)
          .where((party) => party.id == partyId)
          .firstOrNull;
      if (fromList != null) return fromList;

      final fromPicker = ref
          .read(partyPickerListProvider)
          .value
          ?.where((party) => party.id == partyId)
          .firstOrNull;
      if (fromPicker != null) return fromPicker;
    }

    final name = widget.value.trim();
    if (name.isEmpty) return null;

    return ref
            .read(partiesListProvider)
            .where((party) => party.name == name)
            .firstOrNull ??
        ref
            .read(partyPickerListProvider)
            .value
            ?.where((party) => party.name == name)
            .firstOrNull;
  }

  Future<void> _openEditPartyDialog() async {
    final party = _resolveSelectedParty();
    if (party == null) return;

    _removeOverlay();
    final result = await showEditPartyDialog(context, party: party);
    if (!mounted || result == null) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partiesListProvider);

    widget.onSelected(result.partyName);

    var match = ref
        .read(partiesListProvider)
        .where((item) => item.id == party.id)
        .firstOrNull;

    if (match == null) {
      try {
        final pickerParties = await ref.read(partyPickerListProvider.future);
        match = pickerParties
            .where((item) => item.id == party.id)
            .firstOrNull;
      } on Object {
        // Picker refresh is best-effort after edit.
      }
    }

    if (match != null) {
      _lastSelectedPartyId = match.id;
      widget.onPartySelected?.call(match);
      widget.onPartySelectedWithId?.call(match.id, match.name);
    }
    widget.onPartyCreated?.call(result);
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
            ),
          ),
          CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, renderBox.size.height + 4),
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: renderBox.size.width,
                height: 280,
                child: _buildOverlayContent(),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  Widget _buildOverlayContent() {
    final partiesAsync = ref.watch(partyPickerListProvider);
    final filtered = _filteredParties;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: TextField(
            autofocus: true,
            decoration: buildSaleFieldDecoration(hint: 'Search party…'),
            onChanged: (value) {
              setState(() => _searchQuery = value);
              _overlayEntry?.markNeedsBuild();
            },
          ),
        ),
        Expanded(
          child: partiesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(PartyErrorMapper.messageFor(error)),
            ),
            data: (_) {
              if (filtered.isEmpty) {
                return const Center(child: Text('No parties found'));
              }

              return ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final party = filtered[index];
                  final subtitle = [
                    if (party.phone.isNotEmpty) party.phone,
                    if (party.gstin.isNotEmpty) party.gstin,
                  ].join(' · ');

                  return ListTile(
                    dense: true,
                    leading: PartyAvatar(
                      name: party.name,
                      seed: party.id,
                      partyId: party.id,
                      diameter: 32,
                      profileImageUrl: party.profileImageUrl,
                      profileMediaAssetId: party.profileMediaAssetId,
                    ),
                    title: AppEllipsisText(party.name),
                    subtitle: subtitle.isEmpty ? null : Text(subtitle),
                    onTap: () => _selectParty(party),
                  );
                },
              );
            },
          ),
        ),
        const Divider(height: 1),
        ListTile(
          dense: true,
          leading: const Icon(Icons.add, color: AppColors.primary),
          title: const Text('+ Add New Party'),
          onTap: _openAddPartyDialog,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // OverlayEntry does not rebuild when async providers resolve; refresh it
    // manually so the loading spinner is replaced with party results.
    ref.listen(partyPickerListProvider, (_, _) {
      _overlayEntry?.markNeedsBuild();
    });

    final displayValue = widget.value.isEmpty
        ? widget.emptyPlaceholder
        : widget.value;
    final canEditParty = widget.value.isNotEmpty;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration:
              buildSaleFieldDecoration(
                hasError: widget.hasError,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (canEditParty)
                      IconButton(
                        onPressed: _openEditPartyDialog,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        color: AppColors.textSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: 'Edit party',
                      ),
                    const Icon(Icons.arrow_drop_down),
                    const SizedBox(width: 4),
                  ],
                ),
              ).copyWith(
                errorText: widget.hasError ? widget.errorMessage : null,
              ),
          child: AppEllipsisText(
            displayValue,
            style: TextStyle(
              color: widget.value.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
