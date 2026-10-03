import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/item_images_provider.dart';
import 'package:billing_baba/features/inventory/models/add_item_form_model.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/shared/widgets/app_network_image.dart';
import 'package:billing_baba/shared/widgets/forms/forms.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _tableMinWidth = 1340.0;
const _ratingColumnWidth = 96.0;
const _thumbSize = 36.0;

const _paymentPolicyOptions = [
  '',
  'Net 7',
  'Net 15',
  'Net 30',
  'Net 45',
  'Cash on delivery',
  'Advance payment',
  'Credit',
];

const _tableHeaderStyle = TextStyle(
  fontSize: 10,
  fontWeight: FontWeight.w700,
  letterSpacing: 0.4,
  color: AppColors.textSecondary,
);

final _decimalInputFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'^\d*\.?\d*'),
);

bool _isSupplierParty(PartyModel party) {
  final type = party.partyType.toLowerCase();
  return type == 'supplier' || type == 'both';
}

/// Suppliers tab — editable table with auto-filled product and party details.
class SuppliersSection extends ConsumerStatefulWidget {
  const SuppliersSection({
    required this.rows,
    required this.product,
    required this.onPartiesSelected,
    required this.onUpdateRow,
    required this.onRemoveRow,
    this.defaultPartyId,
    this.onDefaultChanged,
    super.key,
  });

  final List<ItemSupplierFormRow> rows;
  final SuppliersProductSnapshot product;
  final void Function(
    List<String> partyIds,
    Map<String, PartyModel> partiesById,
    String? resolvedImageUrl,
  )
  onPartiesSelected;
  final ValueChanged<ItemSupplierFormRow> onUpdateRow;
  final ValueChanged<String> onRemoveRow;
  final String? defaultPartyId;
  final ValueChanged<String?>? onDefaultChanged;

  @override
  ConsumerState<SuppliersSection> createState() => _SuppliersSectionState();
}

class _SuppliersSectionState extends ConsumerState<SuppliersSection> {
  final Map<String, TextEditingController> _brandControllers = {};
  final Map<String, TextEditingController> _mrpControllers = {};
  final Map<String, TextEditingController> _pricingControllers = {};
  final Map<String, TextEditingController> _moqControllers = {};
  final Map<String, TextEditingController> _notesControllers = {};
  final Map<String, TextEditingController> _addressControllers = {};

  @override
  void dispose() {
    for (final controller in [
      ..._brandControllers.values,
      ..._mrpControllers.values,
      ..._pricingControllers.values,
      ..._moqControllers.values,
      ..._notesControllers.values,
      ..._addressControllers.values,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(
    Map<String, TextEditingController> store,
    String partyId,
    String text,
  ) {
    final existing = store[partyId];
    if (existing != null) {
      if (existing.text != text) {
        existing.value = existing.value.copyWith(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
      return existing;
    }
    final controller = TextEditingController(text: text);
    store[partyId] = controller;
    return controller;
  }

  void _pruneControllers() {
    final active = widget.rows.map((row) => row.partyId).toSet();
    void prune(Map<String, TextEditingController> store) {
      for (final id in store.keys.toList()) {
        if (!active.contains(id)) {
          store.remove(id)?.dispose();
        }
      }
    }

    prune(_brandControllers);
    prune(_mrpControllers);
    prune(_pricingControllers);
    prune(_moqControllers);
    prune(_notesControllers);
    prune(_addressControllers);
  }

  Map<String, PartyModel> _partiesById() {
    final parties = ref.watch(partiesListProvider);
    final partiesById = {for (final party in parties) party.id: party};
    final pickerParties = ref.watch(partyPickerListProvider).value ?? const [];
    for (final party in pickerParties) {
      partiesById.putIfAbsent(party.id, () => party);
    }
    return partiesById;
  }

  String? _resolvedProductImageUrl() {
    final fromForm = widget.product.productImageUrl.trim();
    if (fromForm.isNotEmpty) return fromForm;

    final itemId = widget.product.itemId?.trim();
    if (itemId == null || itemId.isEmpty) return null;

    final images = ref.watch(itemImagesProvider(itemId)).value ?? const [];
    if (images.isEmpty) return null;
    final sorted = List.of(images)
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    final url = sorted.first.urlForGrid().trim();
    return url.isEmpty ? null : url;
  }

  void _applyPartySelection(List<String> partyIds) {
    widget.onPartiesSelected(
      partyIds,
      _partiesById(),
      _resolvedProductImageUrl(),
    );
  }

  Future<void> _openPicker() async {
    final partiesAsync = ref.read(partyPickerListProvider);
    List<PartyModel> parties;
    try {
      parties =
          partiesAsync.value ?? await ref.read(partyPickerListProvider.future);
    } on Object {
      parties = ref.read(partiesListProvider);
    }

    if (!mounted) return;
    final currentIds = widget.rows.map((row) => row.partyId).toList();
    final picked = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => _SupplierPartiesPickerDialog(
        parties: parties,
        initialSelection: currentIds,
      ),
    );
    if (picked != null) _applyPartySelection(picked);
  }

  Future<void> _addParty() async {
    final result = await showAddPartyDialog(context);
    if (result == null || !mounted) return;

    ref
      ..invalidate(partyPickerListProvider)
      ..invalidate(partyListProvider);

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

    if (match == null || !mounted) return;
    final currentIds = widget.rows.map((row) => row.partyId).toList();
    if (currentIds.contains(match.id)) return;
    _applyPartySelection([...currentIds, match.id]);
  }

  @override
  Widget build(BuildContext context) {
    _pruneControllers();
    final partiesById = _partiesById();
    final imageUrl = _resolvedProductImageUrl();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 22,
              color: AppColors.primary,
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Suppliers',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Manage your suppliers and purchase details for this product.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            OutlinedButton(
              onPressed: _addParty,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(color: _cardBorder),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              child: const Text('Add Party'),
            ),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: _openPicker,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add Supplier'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final tableWidth = constraints.maxWidth < _tableMinWidth
                ? _tableMinWidth
                : constraints.maxWidth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: tableWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: _cardBorder),
                    borderRadius: BorderRadius.circular(8),
                    color: AppColors.surface,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _SuppliersTableHeader(),
                      if (widget.rows.isEmpty)
                        const _SuppliersEmptyTableBody()
                      else
                        ...widget.rows.asMap().entries.map(
                          (entry) => _SupplierEditableRow(
                            index: entry.key + 1,
                            row: entry.value,
                            partyName: partiesById[entry.value.partyId]?.name,
                            imageUrl: entry.value.productImageUrl.isNotEmpty
                                ? entry.value.productImageUrl
                                : imageUrl,
                            isDefault:
                                entry.value.partyId ==
                                (widget.defaultPartyId ??
                                    widget.rows.first.partyId),
                            brandController: _controllerFor(
                              _brandControllers,
                              entry.value.partyId,
                              entry.value.brandName,
                            ),
                            mrpController: _controllerFor(
                              _mrpControllers,
                              entry.value.partyId,
                              _formatDecimal(entry.value.mrp),
                            ),
                            pricingController: _controllerFor(
                              _pricingControllers,
                              entry.value.partyId,
                              _formatDecimal(entry.value.pricing),
                            ),
                            moqController: _controllerFor(
                              _moqControllers,
                              entry.value.partyId,
                              _formatDecimal(entry.value.minOrderQuantity),
                            ),
                            notesController: _controllerFor(
                              _notesControllers,
                              entry.value.partyId,
                              entry.value.notes,
                            ),
                            addressController: _controllerFor(
                              _addressControllers,
                              entry.value.partyId,
                              entry.value.sellerAddress,
                            ),
                            onChanged: widget.onUpdateRow,
                            onRemove: () =>
                                widget.onRemoveRow(entry.value.partyId),
                            onSetDefault: widget.onDefaultChanged == null
                                ? null
                                : () => widget.onDefaultChanged!(
                                    entry.value.partyId,
                                  ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

String _formatDecimal(double value) {
  if (value == 0) return '';
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

class _SuppliersTableHeader extends StatelessWidget {
  const _SuppliersTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FA),
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: _tableHeaderStyle)),
          SizedBox(width: 52, child: Text('IMAGE', style: _tableHeaderStyle)),
          Expanded(
            flex: 2,
            child: Text('BRAND NAME', style: _tableHeaderStyle),
          ),
          Expanded(child: Text('MRP (₹)', style: _tableHeaderStyle)),
          Expanded(child: Text('PRICING (₹)', style: _tableHeaderStyle)),
          Expanded(child: Text('MIN. ORDER QTY', style: _tableHeaderStyle)),
          Expanded(
            flex: 2,
            child: Text('PAYMENT POLICY', style: _tableHeaderStyle),
          ),
          SizedBox(
            width: _ratingColumnWidth,
            child: Text('QUALITY RATING', style: _tableHeaderStyle),
          ),
          Expanded(flex: 2, child: Text('NOTES', style: _tableHeaderStyle)),
          Expanded(
            flex: 2,
            child: Text('SELLER ADDRESS', style: _tableHeaderStyle),
          ),
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}

class _SuppliersEmptyTableBody extends StatelessWidget {
  const _SuppliersEmptyTableBody();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 36,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No suppliers added yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Use Add Supplier to link parties — product and address fields fill automatically.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _SupplierEditableRow extends StatelessWidget {
  const _SupplierEditableRow({
    required this.index,
    required this.row,
    required this.brandController,
    required this.mrpController,
    required this.pricingController,
    required this.moqController,
    required this.notesController,
    required this.addressController,
    required this.onChanged,
    required this.onRemove,
    this.partyName,
    this.imageUrl,
    this.isDefault = false,
    this.onSetDefault,
  });

  final int index;
  final ItemSupplierFormRow row;
  final String? partyName;
  final String? imageUrl;
  final bool isDefault;
  final TextEditingController brandController;
  final TextEditingController mrpController;
  final TextEditingController pricingController;
  final TextEditingController moqController;
  final TextEditingController notesController;
  final TextEditingController addressController;
  final ValueChanged<ItemSupplierFormRow> onChanged;
  final VoidCallback onRemove;
  final VoidCallback? onSetDefault;

  void _patch(
    ItemSupplierFormRow Function(ItemSupplierFormRow current) transform,
  ) {
    onChanged(transform(row));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDefault ? AppColors.primary.withValues(alpha: 0.03) : null,
        border: const Border(bottom: BorderSide(color: _cardBorder)),
      ),
      child: ClipRect(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 28,
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '$index',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 52,
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: _ProductImageThumb(url: imageUrl),
              ),
            ),
            Expanded(
              flex: 2,
              child: _CompactField(
                controller: brandController,
                hint: 'Enter brand name',
                onChanged: (value) =>
                    _patch((r) => r.copyWith(brandName: value)),
              ),
            ),
            Expanded(
              child: _CompactField(
                controller: mrpController,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_decimalInputFormatter],
                onChanged: (value) => _patch(
                  (r) => r.copyWith(mrp: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            Expanded(
              child: _CompactField(
                controller: pricingController,
                hint: '0.00',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_decimalInputFormatter],
                onChanged: (value) => _patch(
                  (r) => r.copyWith(pricing: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            Expanded(
              child: _CompactField(
                controller: moqController,
                hint: '1',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [_decimalInputFormatter],
                onChanged: (value) => _patch(
                  (r) => r.copyWith(
                    minOrderQuantity: double.tryParse(value) ?? 1,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: _PaymentPolicyField(
                value: row.paymentPolicy,
                onChanged: (value) =>
                    _patch((r) => r.copyWith(paymentPolicy: value)),
              ),
            ),
            SizedBox(
              width: _ratingColumnWidth,
              child: _QualityRatingField(
                rating: row.qualityRating,
                onChanged: (value) =>
                    _patch((r) => r.copyWith(qualityRating: value)),
              ),
            ),
            Expanded(
              flex: 2,
              child: _CompactField(
                controller: notesController,
                hint: 'Add notes',
                minLines: 2,
                maxLines: 3,
                onChanged: (value) => _patch((r) => r.copyWith(notes: value)),
              ),
            ),
            Expanded(
              flex: 2,
              child: _CompactField(
                controller: addressController,
                hint: 'Enter seller address',
                minLines: 2,
                maxLines: 3,
                onChanged: (value) =>
                    _patch((r) => r.copyWith(sellerAddress: value)),
              ),
            ),
            SizedBox(
              width: 32,
              child: PopupMenuButton<String>(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (action) {
                  switch (action) {
                    case 'default':
                      onSetDefault?.call();
                    case 'remove':
                      onRemove();
                  }
                },
                itemBuilder: (context) => [
                  if (onSetDefault != null)
                    PopupMenuItem(
                      value: 'default',
                      enabled: !isDefault,
                      child: Text(
                        isDefault ? 'Default supplier' : 'Set as default',
                      ),
                    ),
                  if (partyName != null && partyName!.trim().isNotEmpty)
                    PopupMenuItem(
                      enabled: false,
                      child: Text(
                        partyName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: Text(
                      'Remove supplier',
                      style: TextStyle(color: Color(0xFFD32F2F)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactField extends StatelessWidget {
  const _CompactField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.keyboardType,
    this.inputFormatters,
    this.minLines = 1,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        style: saleFieldTextStyle.copyWith(fontSize: 12),
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        minLines: minLines,
        maxLines: maxLines,
        decoration: buildSaleFieldDecoration(
          hint: hint,
          compact: true,
          fixedHeight: minLines == 1,
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _PaymentPolicyField extends StatelessWidget {
  const _PaymentPolicyField({
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

  static final _options = _paymentPolicyOptions
      .where((option) => option.isNotEmpty)
      .toList();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SaleGenericSelectDropdown(
        compact: true,
        value: value,
        hintText: 'Select policy',
        options: _options,
        onSelected: onChanged,
      ),
    );
  }
}

class _QualityRatingField extends StatelessWidget {
  const _QualityRatingField({
    required this.rating,
    required this.onChanged,
  });

  final int rating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        height: saleCompactFieldHeight,
        child: Align(
          alignment: Alignment.centerLeft,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (starIndex) {
                final filled = starIndex < rating;
                return InkWell(
                  onTap: () => onChanged(starIndex + 1),
                  borderRadius: BorderRadius.circular(4),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Icon(
                      filled ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 16,
                      color: filled
                          ? const Color(0xFFFFB300)
                          : Colors.grey.shade400,
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductImageThumb extends StatelessWidget {
  const _ProductImageThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.trim().isEmpty) {
      return Container(
        width: _thumbSize,
        height: _thumbSize,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: _cardBorder),
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFFF5F5F5),
        ),
        child: Icon(
          Icons.image_outlined,
          size: 18,
          color: Colors.grey.shade500,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: AppNetworkImage(
        imageUrl: url!,
        width: _thumbSize,
        height: _thumbSize,
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

    ref
      ..invalidate(partyPickerListProvider)
      ..invalidate(partyListProvider);

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
