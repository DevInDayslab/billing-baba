import 'package:billing_baba/core/theme/app_theme.dart';
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
const _popupMaxHeight = 320.0;
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
      filters.selectedPaymentType != 'All Payment Types',
    PurchaseBillColumnFilterKind.amount =>
      filters.amountMin != null || filters.amountMax != null,
    PurchaseBillColumnFilterKind.balanceDue =>
      filters.balanceMin != null || filters.balanceMax != null,
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

    final menuWidth = renderBox.size.width < _popupMinWidth
        ? _popupMinWidth
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
                elevation: 4,
                shadowColor: Colors.black26,
                color: AppColors.surface,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
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
      PurchaseBillColumnFilterKind.paymentType => _OptionListPanel(
        options: ['All Payment Types', ...SaleDropdownOptions.paymentTypes],
        selected: filters.selectedPaymentType,
        onSelected: (value) {
          notifier.setPaymentType(value);
          onCloseAfterSelect();
        },
      ),
      PurchaseBillColumnFilterKind.amount => _NumericRangePanel(
        initialMin: filters.amountMin,
        initialMax: filters.amountMax,
        onChanged: notifier.setAmountRange,
        onClear: () => notifier.setAmountRange(),
      ),
      PurchaseBillColumnFilterKind.balanceDue => _NumericRangePanel(
        initialMin: filters.balanceMin,
        initialMax: filters.balanceMax,
        onChanged: notifier.setBalanceRange,
        onClear: () => notifier.setBalanceRange(),
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

    final trigger = Align(
      alignment: widget.alignment,
      child: InkWell(
        onTap: _onFilterTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
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
              const SizedBox(width: 4),
              Icon(Icons.filter_list, size: 14, color: filterColor),
            ],
          ),
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
      child: Align(
        alignment: widget.alignment,
        widthFactor: 1,
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

class _NumericRangePanel extends StatefulWidget {
  const _NumericRangePanel({
    required this.initialMin,
    required this.initialMax,
    required this.onChanged,
    required this.onClear,
  });

  final double? initialMin;
  final double? initialMax;
  final void Function({double? min, double? max}) onChanged;
  final VoidCallback onClear;

  @override
  State<_NumericRangePanel> createState() => _NumericRangePanelState();
}

class _NumericRangePanelState extends State<_NumericRangePanel> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: widget.initialMin?.toStringAsFixed(0) ?? '',
    );
    _maxController = TextEditingController(
      text: widget.initialMax?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      min: _parseAmount(_minController.text),
      max: _parseAmount(_maxController.text),
    );
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
            controller: _minController,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Min',
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _maxController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Max',
              isDense: true,
            ),
            style: const TextStyle(fontSize: 13),
            onChanged: (_) => _emit(),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                _minController.clear();
                _maxController.clear();
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
