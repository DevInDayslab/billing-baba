import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/application/party_error_mapper.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Searchable party picker with "+ Add New Party" action.
class PartySearchField extends ConsumerStatefulWidget {
  const PartySearchField({
    required this.value,
    required this.onSelected,
    this.onPartySelectedWithId,
    this.onPartyCreated,
    this.hasError = false,
    this.emptyPlaceholder = 'Select party',
    this.errorMessage = 'Billing name is required',
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
  final void Function(String partyId, String partyName)? onPartySelectedWithId;
  final ValueChanged<AddPartyResult>? onPartyCreated;
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

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void closeMenu() => _removeOverlay();

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
    } else {
      _searchQuery = '';
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectParty(String party) {
    _removeOverlay();
    widget.onSelected(party);

    final parties = ref.read(partiesListProvider);
    final match = parties.where((item) => item.name == party).firstOrNull;
    if (match != null) {
      widget.onPartySelectedWithId?.call(match.id, match.name);
    }
  }

  List<String> get _filteredParties {
    final parties = ref.watch(partyNamesProvider);
    if (_searchQuery.isEmpty) return parties;
    final query = _searchQuery.toLowerCase();
    return parties
        .where((party) => party.toLowerCase().contains(query))
        .toList();
  }

  Future<void> _openAddPartyDialog() async {
    _removeOverlay();
    final result = await showAddPartyDialog(context);
    if (!mounted || result == null) return;

    try {
      await ref.read(partyListProvider.notifier).createParty(result);
    } on PartyOfflineException {
      if (!mounted) return;
    } on ApiValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
      return;
    } on PartyException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: AppColors.error),
      );
      return;
    }

    if (!mounted) return;
    widget.onSelected(result.partyName);
    final parties = ref.read(partiesListProvider);
    final match =
        parties.where((party) => party.name == result.partyName).firstOrNull;
    if (match != null) {
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
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: renderBox.size.width,
                  maxHeight: 280,
                ),
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
    final partiesAsync = ref.watch(partyListProvider);
    final filtered = _filteredParties;

    return Column(
      mainAxisSize: MainAxisSize.min,
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
        Flexible(
          child: partiesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, _) => Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(PartyErrorMapper.messageFor(error)),
            ),
            data: (_) {
              if (filtered.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(AppSpacing.md),
                  child: Text('No parties found'),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final party = filtered[index];
                  return ListTile(
                    dense: true,
                    title: Text(party),
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
    final displayValue = widget.value.isEmpty
        ? widget.emptyPlaceholder
        : widget.value;

    return CompositedTransformTarget(
      link: _layerLink,
      child: InkWell(
        onTap: _toggleMenu,
        borderRadius: BorderRadius.circular(8),
        child: InputDecorator(
          decoration:
              buildSaleFieldDecoration(
                hasError: widget.hasError,
                suffixIcon: const Icon(Icons.arrow_drop_down),
              ).copyWith(
                errorText: widget.hasError ? widget.errorMessage : null,
              ),
          child: Text(
            displayValue,
            style: TextStyle(
              color: widget.value.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
