import 'dart:async';

import 'package:billing_baba/shared/forms/transaction_form_validation.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _fieldBorder = Color(0xFFE0E0E0);
const _saveBlue = AppColors.primary;

/// Vyapar-style customer field with inline saved-parties list.
class MobileSalePartyPickerField extends ConsumerStatefulWidget {
  const MobileSalePartyPickerField({
    required this.controller,
    required this.selectedPartyId,
    required this.onPartySelected,
    required this.onSearchChanged,
    super.key,
    this.hasError = false,
    this.partyTypeFilter = PartyTypeFilter.customer,
  });

  final TextEditingController controller;
  final String? selectedPartyId;
  final ValueChanged<PartyModel> onPartySelected;
  final ValueChanged<String> onSearchChanged;
  final bool hasError;
  final PartyTypeFilter partyTypeFilter;

  @override
  ConsumerState<MobileSalePartyPickerField> createState() =>
      _MobileSalePartyPickerFieldState();
}

class _MobileSalePartyPickerFieldState
    extends ConsumerState<MobileSalePartyPickerField> {
  final FocusNode _focusNode = FocusNode();
  var _isExpanded = false;
  var _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final partiesAsync = ref.read(partyPickerListProvider);
      if (!partiesAsync.hasValue || (partiesAsync.value?.isEmpty ?? true)) {
        unawaited(ref.read(partyPickerListProvider.future));
      }
    });
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChange)
      ..dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus) {
      setState(() => _isExpanded = true);
    }
  }

  void _collapse() {
    if (!_isExpanded) return;
    setState(() => _isExpanded = false);
    _focusNode.unfocus();
  }

  void _expand() {
    final partiesAsync = ref.read(partyPickerListProvider);
    if (!partiesAsync.hasValue || (partiesAsync.value?.isEmpty ?? true)) {
      unawaited(ref.read(partyPickerListProvider.future));
    }
    setState(() {
      _isExpanded = true;
      _searchQuery = widget.controller.text.trim();
    });
    _focusNode.requestFocus();
  }

  List<PartyModel> _filteredParties(List<PartyModel> parties) {
    final filtered = parties
        .where((party) => widget.partyTypeFilter.matches(party.partyType))
        .toList();

    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return filtered;

    return filtered.where((party) {
      final searchable = [
        party.name,
        party.phone,
        party.gstin,
        party.email,
      ].join(' ').toLowerCase();
      return searchable.contains(query);
    }).toList();
  }

  void _selectParty(PartyModel party) {
    widget.controller.text = party.name;
    widget.onPartySelected(party);
    _collapse();
  }

  Future<void> _addNewParty() async {
    _collapse();
    final result = await showAddPartyDialog(context);
    if (!mounted || result == null) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partiesListProvider);

    widget.controller.text = result.partyName;
    widget.onSearchChanged(result.partyName);

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

    if (match != null && mounted) {
      widget.onPartySelected(match);
    }
  }

  String _balanceLabel(PartyModel party) {
    if (party.balance == 0) return '0';
    return PartyModel.displayOutstanding(party.balance);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partiesAsync = ref.watch(partyPickerListProvider);
    final borderColor = widget.hasError ? AppColors.error : _fieldBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            children: const [
              TextSpan(text: 'Customer'),
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          onTap: _expand,
          onChanged: (value) {
            setState(() => _searchQuery = value);
            widget.onSearchChanged(value);
            if (!_isExpanded) setState(() => _isExpanded = true);
          },
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Customer name',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondary.withValues(alpha: 0.55),
            ),
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: BorderSide(
                color: widget.hasError ? AppColors.error : _saveBlue,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: AppRadius.mdBorder,
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
        if (widget.hasError) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            kPartyValidationMessage,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
          ),
        ],
        if (_isExpanded) ...[
          const SizedBox(height: AppSpacing.sm),
          Material(
            color: AppColors.surface,
            elevation: 2,
            shadowColor: Colors.black.withValues(alpha: 0.08),
            borderRadius: AppRadius.mdBorder,
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Showing Saved Parties',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _addNewParty,
                        child: Text(
                          'Add new party',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _saveBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                partiesAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, _) => Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Text(
                      PartyErrorMapper.messageFor(error),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                  data: (parties) {
                    final filtered = _filteredParties(parties);
                    if (filtered.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          0,
                          AppSpacing.md,
                          AppSpacing.lg,
                        ),
                        child: Text(
                          'No parties found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        for (var i = 0; i < filtered.length; i++) ...[
                          if (i > 0)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.12,
                              ),
                            ),
                          _PartyRow(
                            party: filtered[i],
                            balanceLabel: _balanceLabel(filtered[i]),
                            isSelected:
                                widget.selectedPartyId == filtered[i].id,
                            onTap: () => _selectParty(filtered[i]),
                          ),
                        ],
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.party,
    required this.balanceLabel,
    required this.onTap,
    this.isSelected = false,
  });

  final PartyModel party;
  final String balanceLabel;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: isSelected ? _saveBlue.withValues(alpha: 0.06) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      party.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (party.phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        party.phone,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                balanceLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary.withValues(alpha: 0.55),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
