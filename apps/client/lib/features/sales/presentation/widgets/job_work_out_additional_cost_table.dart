import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/models/job_work_out_form_model.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_field_decoration.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_generic_select_dropdown.dart';
import 'package:billing_baba/features/sales/providers/job_work_out_form_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _cardBorder = Color(0xFFE0E0E0);
const _headerBackground = Color(0xFFF5F5F5);
const _rowHeight = 44.0;
const _deleteColWidth = 28.0;
const _addRowButtonColor = Color(0xFF1565C0);

class JobWorkOutAdditionalCostTable extends ConsumerWidget {
  const JobWorkOutAdditionalCostTable({super.key});

  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(jobWorkOutFormProvider);
    final notifier = ref.read(jobWorkOutFormProvider.notifier);

    if (form.additionalCosts.isEmpty) return const SizedBox.shrink();

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _cardBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Text(
              'Additional Cost',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Divider(height: 1, color: _cardBorder),
          const _TableHeaderRow(),
          const Divider(height: 1, color: _cardBorder),
          for (var i = 0; i < form.additionalCosts.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: _cardBorder),
            _AdditionalCostRow(index: i, item: form.additionalCosts[i]),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: notifier.addAdditionalCost,
                style: TextButton.styleFrom(
                  foregroundColor: _addRowButtonColor,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'Add Row',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          Container(
            color: _headerBackground,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                const Spacer(),
                const Text(
                  'TOTAL:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  _currencyFormat.format(form.additionalCostsTotal),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeaderRow extends StatelessWidget {
  const _TableHeaderRow();

  static const _headerStyle = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _headerBackground,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Row(
        children: [
          SizedBox(width: 28, child: Text('#', style: _headerStyle)),
          Expanded(flex: 3, child: Text('CHARGES', style: _headerStyle)),
          SizedBox(
            width: 140,
            child: Text(
              'ESTIMATED COST',
              style: _headerStyle,
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(width: _deleteColWidth),
        ],
      ),
    );
  }
}

class _AdditionalCostRow extends ConsumerWidget {
  const _AdditionalCostRow({required this.index, required this.item});

  final int index;
  final JobWorkOutAdditionalCost item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(jobWorkOutFormProvider.notifier);

    return SizedBox(
      height: _rowHeight,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: SaleGenericSelectDropdown(
                value: item.label.isEmpty
                    ? SaleDropdownOptions.jobWorkAdditionalCostCharges.first
                    : item.label,
                options: SaleDropdownOptions.jobWorkAdditionalCostCharges,
                hintText: 'Select charge',
                compact: true,
                onSelected: (value) => notifier.updateAdditionalCost(
                  item.id,
                  item.copyWith(label: value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 132,
              child: _CompactTextField(
                initialValue: item.amount == 0 ? '0' : item.amount.toString(),
                hintText: '0',
                textAlign: TextAlign.right,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (value) => notifier.updateAdditionalCost(
                  item.id,
                  item.copyWith(amount: double.tryParse(value) ?? 0),
                ),
              ),
            ),
            SizedBox(
              width: _deleteColWidth,
              child: IconButton(
                onPressed: () => notifier.removeAdditionalCost(item.id),
                icon: const Icon(Icons.close, size: 16, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                tooltip: 'Remove row',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompactTextField extends StatefulWidget {
  const _CompactTextField({
    required this.initialValue,
    required this.onChanged,
    this.hintText,
    this.textAlign = TextAlign.left,
    this.keyboardType,
    this.inputFormatters,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final String? hintText;
  final TextAlign textAlign;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<_CompactTextField> createState() => _CompactTextFieldState();
}

class _CompactTextFieldState extends State<_CompactTextField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(_CompactTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      style: saleFieldTextStyle.copyWith(fontSize: 13),
      textAlign: widget.textAlign,
      decoration: buildSaleFieldDecoration(
        hint: widget.hintText,
        compact: true,
      ),
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
    );
  }
}
