import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/parties/models/party_type_filter.dart';
import 'package:billing_baba/features/purchases/presentation/utils/transaction_form_save_flow.dart';
import 'package:billing_baba/features/sales/application/add_sale_fa_form_provider.dart';
import 'package:billing_baba/features/sales/models/sale_fa_form_model.dart';
import 'package:billing_baba/shared/widgets/mobile/forms/mobile_forms.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:lucide_icons_flutter/lucide_icons.dart';

class MobileAddSaleFaPage extends ConsumerStatefulWidget {
  const MobileAddSaleFaPage({
    super.key,
    this.batchId,
  });

  final String? batchId;

  @override
  ConsumerState<MobileAddSaleFaPage> createState() =>
      _MobileAddSaleFaPageState();
}

class _MobileAddSaleFaPageState extends ConsumerState<MobileAddSaleFaPage> {
  final _dateFormat = DateFormat('dd MMM yyyy');
  late final String _sessionKey;

  @override
  void initState() {
    super.initState();
    _sessionKey = widget.batchId ?? 'mobile_sale_fa_new';
    if (widget.batchId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(addSaleFaFormProvider(sessionKey: _sessionKey).notifier)
            .loadBatch(widget.batchId!);
      });
    }
  }

  AddSaleFaFormState _form() =>
      ref.watch(addSaleFaFormProvider(sessionKey: _sessionKey));

  AddSaleFaForm _notifier() =>
      ref.read(addSaleFaFormProvider(sessionKey: _sessionKey).notifier);

  Future<void> _pickParty() async {
    final party = await showMobilePartyPickerSheet(
      context,
      typeFilter: PartyTypeFilter.customer,
      title: 'Select customer',
    );
    if (party != null) {
      _notifier().updateParty(party.name, partyId: party.id);
    }
  }

  void _addFaLine() {
    _notifier().addLineItem();
  }

  Future<void> _save() async {
    final error = await _notifier().save();
    showMobileFormResult(
      context,
      error: error,
      successMessage: 'Sale FA saved',
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = _form();
    final isEdit = widget.batchId != null;

    return MobileFormScaffold(
      title: isEdit ? 'Edit sale FA' : 'Add sale FA',
      isLoading: form.isLoading,
      isSaving: form.isSaving,
      primaryActionLabel: 'Save',
      onPrimaryAction: _save,
      onBack: () => leaveTransactionFormPage(
        context: context,
        isDirty: form.isDirty,
        isSaving: form.isSaving,
        listRoute: AppRoutes.saleFa,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (form.saveError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Text(
                form.saveError!,
                style: AppTypography.inter(
                  fontSize: AppTypography.bodySize,
                  color: AppColors.error,
                ),
              ),
            ),
          MobileFormPickerField(
            label: 'Customer',
            value: form.party,
            onTap: _pickParty,
          ),
          MobileFormPickerField(
            label: 'Sale date',
            value: form.saleDate != null
                ? _dateFormat.format(form.saleDate!)
                : '',
            onTap: () async {
              final date = await showMobileDatePicker(
                context,
                initialDate: form.saleDate,
              );
              if (date != null) _notifier().updateSaleDate(date);
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          _FaLinesSection(
            items: form.items,
            onAdd: _addFaLine,
            onRemove: _notifier().removeLineItem,
            onChanged: _notifier().updateLineItem,
          ),
          MobileDocumentSummaryCard(
            subtotal: form.subtotal,
            tax: form.totalTax,
            total: form.grandTotal,
          ),
        ],
      ),
    );
  }
}

class _FaLinesSection extends StatelessWidget {
  const _FaLinesSection({
    required this.items,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final List<SaleFixedAssetLineItem> items;
  final VoidCallback onAdd;
  final void Function(int index) onRemove;
  final void Function(int index, SaleFixedAssetLineItem item) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              'Assets',
              style: AppTypography.inter(
                fontSize: AppTypography.bodySize,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: onAdd,
              icon: const Icon(LucideIcons.plus, size: 18),
              label: const Text('Add line'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        for (var i = 0; i < items.length; i++)
          _FaLineCard(
            index: i,
            item: items[i],
            onRemove: () => onRemove(i),
            onChanged: (item) => onChanged(i, item),
          ),
      ],
    );
  }
}

class _FaLineCard extends StatefulWidget {
  const _FaLineCard({
    required this.index,
    required this.item,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final SaleFixedAssetLineItem item;
  final VoidCallback onRemove;
  final ValueChanged<SaleFixedAssetLineItem> onChanged;

  @override
  State<_FaLineCard> createState() => _FaLineCardState();
}

class _FaLineCardState extends State<_FaLineCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _qtyController;
  late final TextEditingController _priceController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.assetName);
    _qtyController = TextEditingController(
      text: widget.item.qty > 0 ? widget.item.qty.toString() : '',
    );
    _priceController = TextEditingController(
      text: widget.item.pricePerUnit > 0
          ? widget.item.pricePerUnit.toStringAsFixed(2)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _commit() {
    widget.onChanged(
      widget.item.copyWith(
        assetName: _nameController.text,
        qty: double.tryParse(_qtyController.text) ?? 0,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Line ${widget.index + 1}',
                  style: AppTypography.inter(
                    fontSize: AppTypography.captionSize,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: widget.onRemove,
                  icon: const Icon(LucideIcons.trash2, size: 20),
                ),
              ],
            ),
            MobileFormTextField(
              label: 'Asset name',
              controller: _nameController,
              onChanged: (_) => _commit(),
            ),
            Row(
              children: [
                Expanded(
                  child: MobileFormTextField(
                    label: 'Qty',
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _commit(),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: MobileFormTextField(
                    label: 'Price',
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => _commit(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
