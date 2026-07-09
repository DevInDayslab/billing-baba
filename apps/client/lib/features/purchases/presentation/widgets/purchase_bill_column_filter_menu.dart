import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/filter_icon.dart';
import 'package:billing_baba/features/purchases/providers/purchase_bills_provider.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_date_range_picker.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_dropdown_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _statusOptions = [
  'All Status',
  'Cancelled',
  'Paid',
  'Overdue',
  'Unpaid',
  'Partial',
];

const _popupMinWidth = 200.0;
const _numericPopupMinWidth = 280.0;
const _popupMaxHeight = 360.0;
const _popupOffset = Offset(0, 4);

enum PurchaseBillColumnFilterKind {
  date,
  invoiceNo,
  partyName,
  paymentType,
  amount,
  balanceDue,
  dueDate,
  status,
}

extension PurchaseBillColumnFilterKindX on PurchaseBillColumnFilterKind {
  bool isActive(PurchaseBillFiltersState filters) => switch (this) {
    PurchaseBillColumnFilterKind.date => filters.columnDateRange != null,
    PurchaseBillColumnFilterKind.invoiceNo =>
      filters.invoiceNoFilter.trim().isNotEmpty,
    PurchaseBillColumnFilterKind.partyName =>
      filters.selectedParty != 'All Parties',
    PurchaseBillColumnFilterKind.paymentType =>
      filters.selectedPaymentTypes.isNotEmpty,
    PurchaseBillColumnFilterKind.amount => filters.amountFilter != null,
    PurchaseBillColumnFilterKind.balanceDue => filters.balanceFilter != null,
    PurchaseBillColumnFilterKind.dueDate => filters.dueDateRange != null,
    PurchaseBillColumnFilterKind.status => filters.selectedStatus != 'All Status',
  };
}

/// Header filter trigger with an anchored popup below the filter icon.
class PurchaseBillColumnFilterCell extends ConsumerStatefulWidget {
  const PurchaseBillColumnFilterCell({
    required this.label,
    required this.kind,
    required this.headerStyle,
    this.width,
    this.alignment = Alignment.centerLeft,
    this.gapAfter = 12,
    super.key,
  });

  final String label;
  final PurchaseBillColumnFilterKind kind;
  final TextStyle headerStyle;
  final double? width;
  final Alignment alignment;
  final double gapAfter;

  @override
  ConsumerState<PurchaseBillColumnFilterCell> createState() =>
      _PurchaseBillColumnFilterCellState();
}

class _PurchaseBillColumnFilterCellState
    extends ConsumerState<PurchaseBillColumnFilterCell> {
  final LayerLink _layerLink = LayerLink();
  final GlobalKey<SaleDateRangePickerAnchorState> _datePickerKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  bool get _isDateKind =>
      widget.kind == PurchaseBillColumnFilterKind.date ||
      widget.kind == PurchaseBillColumnFilterKind.dueDate;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _onFilterTap() {
    if (_isDateKind) {
      _datePickerKey.currentState?.toggle();
      return;
    }

    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    _showOverlay();
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final isNumericFilter =
        widget.kind == PurchaseBillColumnFilterKind.amount ||
        widget.kind == PurchaseBillColumnFilterKind.balanceDue;
    final minWidth =
        isNumericFilter ? _numericPopupMinWidth : _popupMinWidth;
    final menuWidth = renderBox.size.width < minWidth
        ? minWidth
        : renderBox.size.width;
    final overlay = Overlay.of(context);

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
              targetAnchor: Alignment.bottomLeft,
              offset: _popupOffset,
              child: Material(
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.12),
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: isNumericFilter ? Clip.none : Clip.antiAlias,
                child: SizedBox(
                  width: menuWidth,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxHeight: _popupMaxHeight,
                    ),
                    child: _buildPopupContent(
                      onClose: _removeOverlay,
                      onCloseAfterSelect: _removeOverlay,
                    ),
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

  Widget _buildPopupContent({
    required VoidCallback onClose,
    required VoidCallback onCloseAfterSelect,
  }) {
    final notifier = ref.read(purchaseBillFiltersProvider.notifier);
    final filters = ref.read(purchaseBillFiltersProvider);

    return switch (widget.kind) {
      PurchaseBillColumnFilterKind.invoiceNo => _TextFilterPanel(
        hint: 'Search invoice no',
        initialValue: filters.invoiceNoFilter,
        onChanged: notifier.setInvoiceNo,
        onClear: () => notifier.setInvoiceNo(''),
      ),
      PurchaseBillColumnFilterKind.partyName => _PartyFilterPanel(
        onSelected: (party) {
          notifier.setParty(party);
          onCloseAfterSelect();
        },
      ),
      PurchaseBillColumnFilterKind.paymentType =>
        const _PaymentTypeCheckboxPanel(),
      PurchaseBillColumnFilterKind.amount => _AdvancedNumericFilterPanel(
        valueLabel: 'Amount',
        initialFilter: filters.amountFilter,
        onApply: (filter) {
          notifier.applyAmountFilter(filter);
          onClose();
        },
        onClear: () {
          notifier.clearAmountFilter();
          onClose();
        },
      ),
      PurchaseBillColumnFilterKind.balanceDue => _AdvancedNumericFilterPanel(
        valueLabel: 'Balance Due',
        initialFilter: filters.balanceFilter,
        onApply: (filter) {
          notifier.applyBalanceFilter(filter);
          onClose();
        },
        onClear: () {
          notifier.clearBalanceFilter();
          onClose();
        },
      ),
      PurchaseBillColumnFilterKind.status => _OptionListPanel(
        options: _statusOptions,
        selected: filters.selectedStatus,
        onSelected: (value) {
          notifier.setStatus(value);
          onCloseAfterSelect();
        },
      ),
      _ => const SizedBox.shrink(),
    };
  }

  DateTimeRange? _initialDateRange(PurchaseBillFiltersState filters) {
    return switch (widget.kind) {
      PurchaseBillColumnFilterKind.date => filters.columnDateRange,
      PurchaseBillColumnFilterKind.dueDate => filters.dueDateRange,
      _ => null,
    };
  }

  void _onDateRangeSelected(DateTimeRange range) {
    final notifier = ref.read(purchaseBillFiltersProvider.notifier);
    switch (widget.kind) {
      case PurchaseBillColumnFilterKind.date:
        notifier.setColumnDateRange(range);
      case PurchaseBillColumnFilterKind.dueDate:
        notifier.setDueDateRange(range);
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(purchaseBillFiltersProvider);
    final isActive = widget.kind.isActive(filters);
    final filterColor = isActive
        ? AppColors.textPrimary
        : AppColors.textSecondary.withValues(alpha: 0.7);

    final trigger = InkWell(
      onTap: _onFilterTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Expanded(
              child: Align(
                alignment: widget.alignment,
                child: Text(
                  widget.label,
                  style: widget.headerStyle.copyWith(
                    color: isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            AppFilterIcon(color: filterColor),
          ],
        ),
      ),
    );

    Widget cellChild;
    if (_isDateKind) {
      cellChild = SaleDateRangePickerAnchor(
        key: _datePickerKey,
        initialRange: _initialDateRange(filters),
        onRangeSelected: _onDateRangeSelected,
        child: trigger,
      );
    } else {
      cellChild = CompositedTransformTarget(
        link: _layerLink,
        child: trigger,
      );
    }

    final content = ClipRect(
      child: SizedBox(
        width: double.infinity,
        child: cellChild,
      ),
    );

    if (widget.width != null) {
      return Padding(
        padding: EdgeInsets.only(right: widget.gapAfter),
        child: SizedBox(width: widget.width, child: content),
      );
    }

    return ClipRect(child: content);
  }
}

class _TextFilterPanel extends StatefulWidget {
  const _TextFilterPanel({
    required this.hint,
    required this.initialValue,
    required this.onChanged,
    required this.onClear,
  });

  final String hint;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<_TextFilterPanel> createState() => _TextFilterPanelState();
}

class _TextFilterPanelState extends State<_TextFilterPanel> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: widget.hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.smBorder,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: widget.onChanged,
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _controller.clear();
                widget.onClear();
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartyFilterPanel extends ConsumerStatefulWidget {
  const _PartyFilterPanel({required this.onSelected});

  final ValueChanged<String> onSelected;

  @override
  ConsumerState<_PartyFilterPanel> createState() => _PartyFilterPanelState();
}

class _PartyFilterPanelState extends ConsumerState<_PartyFilterPanel> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final parties = ref.watch(purchaseBillPartyOptionsProvider);
    final selected = ref.watch(purchaseBillFiltersProvider).selectedParty;
    final filtered = parties
        .where(
          (party) =>
              party == 'All Parties' ||
              party.toLowerCase().contains(_query.toLowerCase()),
        )
        .toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search party',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: AppRadius.smBorder,
              ),
              prefixIcon: const Icon(Icons.search, size: 18),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 36,
                minHeight: 36,
              ),
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final party in filtered)
                _FilterMenuItem(
                  label: party,
                  selected: party == selected,
                  onTap: () => widget.onSelected(party),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentTypeCheckboxPanel extends ConsumerWidget {
  const _PaymentTypeCheckboxPanel();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected =
        ref.watch(purchaseBillFiltersProvider).selectedPaymentTypes;
    final notifier = ref.read(purchaseBillFiltersProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Flexible(
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              for (final option in SaleDropdownOptions.paymentTypes)
                CheckboxListTile(
                  value: selected.contains(option),
                  onChanged: (_) => notifier.togglePaymentType(option),
                  title: Text(
                    option,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm,
            0,
            AppSpacing.sm,
            AppSpacing.xs,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: selected.isEmpty ? null : notifier.clearPaymentTypes,
              child: const Text('Clear'),
            ),
          ),
        ),
      ],
    );
  }
}

class _OptionListPanel extends StatelessWidget {
  const _OptionListPanel({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      children: [
        for (final option in options)
          _FilterMenuItem(
            label: option,
            selected: option == selected,
            onTap: () => onSelected(option),
          ),
      ],
    );
  }
}

class _AdvancedNumericFilterPanel extends StatefulWidget {
  const _AdvancedNumericFilterPanel({
    required this.valueLabel,
    required this.initialFilter,
    required this.onApply,
    required this.onClear,
  });

  final String valueLabel;
  final PurchaseBillNumericFilter? initialFilter;
  final ValueChanged<PurchaseBillNumericFilter> onApply;
  final VoidCallback onClear;

  @override
  State<_AdvancedNumericFilterPanel> createState() =>
      _AdvancedNumericFilterPanelState();
}

class _AdvancedNumericFilterPanelState extends State<_AdvancedNumericFilterPanel> {
  static const _fieldBorderColor = Color(0xFFE2E8F0);
  static const _fieldFillColor = Color(0xFFF8FAFC);

  late PurchaseBillNumericFilterOperator _operator;
  late final TextEditingController _valueController;
  bool _operatorExpanded = false;

  @override
  void initState() {
    super.initState();
    _operator =
        widget.initialFilter?.operator ??
        PurchaseBillNumericFilterOperator.equalTo;
    _valueController = TextEditingController(
      text: widget.initialFilter?.value.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration({
    required String label,
    String? prefixText,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        fontSize: 12,
        color: AppColors.primary,
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: _fieldFillColor,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      prefixText: prefixText,
      prefixStyle: prefixText != null
          ? const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.2,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.smBorder,
        borderSide: const BorderSide(color: _fieldBorderColor),
      ),
    );
  }

  void _handleApply() {
    final value = _parseAmount(_valueController.text);
    if (value == null) return;
    widget.onApply(
      PurchaseBillNumericFilter(operator: _operator, value: value),
    );
  }

  void _handleClear() {
    _valueController.clear();
    setState(() {
      _operator = PurchaseBillNumericFilterOperator.equalTo;
      _operatorExpanded = false;
    });
    widget.onClear();
  }

  void _selectOperator(PurchaseBillNumericFilterOperator operator) {
    setState(() {
      _operator = operator;
      _operatorExpanded = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final canApply = _parseAmount(_valueController.text) != null;

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Filter ${widget.valueLabel}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Select Category',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _InlineOperatorSelector(
            selected: _operator,
            expanded: _operatorExpanded,
            onToggle: () => setState(
              () => _operatorExpanded = !_operatorExpanded,
            ),
            onSelected: _selectOperator,
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _valueController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: _fieldDecoration(
              label: widget.valueLabel,
              prefixText: '₹ ',
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: _fieldBorderColor),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _handleClear,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: _fieldBorderColor),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  child: const Text(
                    'Clear',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: canApply ? _handleApply : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(
                      alpha: 0.4,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.smBorder,
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InlineOperatorSelector extends StatelessWidget {
  const _InlineOperatorSelector({
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.onSelected,
  });

  static const _fieldBorderColor = Color(0xFFE2E8F0);
  static const _fieldFillColor = Color(0xFFF8FAFC);
  static const _optionHoverColor = Color(0xFFF1F5F9);

  final PurchaseBillNumericFilterOperator selected;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<PurchaseBillNumericFilterOperator> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _fieldFillColor,
        borderRadius: AppRadius.smBorder,
        border: Border.all(
          color: expanded ? AppColors.primary : _fieldBorderColor,
          width: expanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onToggle,
              borderRadius: expanded
                  ? const BorderRadius.vertical(top: Radius.circular(7))
                  : AppRadius.smBorder,
              hoverColor: _optionHoverColor,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm + 2,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selected.label,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 180),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1, color: _fieldBorderColor),
            for (final option in PurchaseBillNumericFilterOperator.values)
              _OperatorOptionTile(
                label: option.label,
                selected: option == selected,
                isLast:
                    option == PurchaseBillNumericFilterOperator.values.last,
                onTap: () => onSelected(option),
              ),
          ],
        ],
      ),
    );
  }
}

class _OperatorOptionTile extends StatelessWidget {
  const _OperatorOptionTile({
    required this.label,
    required this.selected,
    required this.isLast,
    required this.onTap,
  });

  static const _optionHoverColor = Color(0xFFF1F5F9);

  final String label;
  final bool selected;
  final bool isLast;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        hoverColor: _optionHoverColor,
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(7))
            : BorderRadius.zero,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 18,
                child: selected
                    ? const Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: AppColors.primary,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight:
                        selected ? FontWeight.w600 : FontWeight.w400,
                    color: selected
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterMenuItem extends StatelessWidget {
  const _FilterMenuItem({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected) const Icon(Icons.check, size: 16),
          ],
        ),
      ),
    );
  }
}

double? _parseAmount(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) return null;
  return double.tryParse(trimmed);
}
