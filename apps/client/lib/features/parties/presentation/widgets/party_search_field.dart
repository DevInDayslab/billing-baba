import 'package:billing_baba/core/theme/app_theme.dart';
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
    this.onPartyCreated,
    this.hasError = false,
    this.emptyPlaceholder = 'Select party',
    this.errorMessage = 'Billing name is required',
    super.key,
  });

  final String value;
  final ValueChanged<String> onSelected;
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
    widget.onSelected(result.partyName);
    widget.onPartyCreated?.call(result);
  }

  void _showOverlay() {
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 280;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _removeOverlay,
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 40),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                color: AppColors.surface,
                child: SizedBox(
                  width: triggerWidth,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: TextField(
                          autofocus: true,
                          style: saleFieldTextStyle,
                          decoration: buildSaleFieldDecoration(
                            hint: 'Search party...',
                          ),
                          onChanged: (value) {
                            setState(() => _searchQuery = value);
                            _overlayEntry?.markNeedsBuild();
                          },
                        ),
                      ),
                      InkWell(
                        onTap: _openAddPartyDialog,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            '+ Add New Party',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const Divider(height: 1),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView(
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          children: [
                            for (final party in _filteredParties)
                              InkWell(
                                onTap: () => _selectParty(party),
                                hoverColor: const Color(0xFFF5F5F5),
                                child: Container(
                                  color: party == widget.value
                                      ? AppColors.primary.withValues(
                                          alpha: 0.08,
                                        )
                                      : null,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          party,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: party == widget.value
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: party == widget.value
                                                ? AppColors.primary
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (party == widget.value)
                                        const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: AppColors.primary,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    final displayText =
        widget.value.isEmpty ? widget.emptyPlaceholder : widget.value;
    final isPlaceholder = widget.value.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CompositedTransformTarget(
          link: _layerLink,
          child: SaleFieldTrigger(
            onTap: _toggleMenu,
            hasError: widget.hasError,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 14,
                      color: isPlaceholder
                          ? Colors.grey.shade400
                          : AppColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        if (widget.hasError)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(
              widget.errorMessage,
              style: const TextStyle(fontSize: 11, color: saleFieldErrorColor),
            ),
          ),
      ],
    );
  }
}
