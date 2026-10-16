import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/models/party_model.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/utils/walk_in_party.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/sales/utils/sale_price_input.dart';
import 'package:billing_baba/features/sale_screen/application/sale_invoice_focus_provider.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_screen_alternative_replace_dialog.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_screen_price_increment_dialog.dart';
import 'package:billing_baba/features/pos/models/cart_item.dart';
import 'package:billing_baba/features/pos/pos_constants.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_item_thumbnail.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/hold_bills_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_invoice_party_ledger_chips.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_screen_share_bill_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

final _money = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 2,
);

final _dateFormat = DateFormat('dd-MM-yyyy');
final _timeFormat = DateFormat('hh:mm a');

const _lineSelectColumnWidth = 40.0;
const _lineMenuColumnWidth = 36.0;

class SaleInvoicePanel extends ConsumerWidget {
  const SaleInvoicePanel({
    required this.cartSessionKey,
    required this.isCompleting,
    required this.onHold,
    required this.onClear,
    required this.onPrint,
    required this.onPay,
    super.key,
  });

  final String cartSessionKey;
  final bool isCompleting;
  final VoidCallback onHold;
  final VoidCallback onClear;
  final VoidCallback onPrint;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(posCartProvider(sessionKey: cartSessionKey));
    final heldBills = cart.heldBills;
    final parties = ref.watch(partyPickerListProvider);
    final now = DateTime.now();
    final textTheme = Theme.of(context).textTheme;

    final invoiceHeader = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Invoice No.',
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Auto',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            Expanded(
              child: heldBills.isEmpty
                  ? const SizedBox.shrink()
                  : Center(
                      child: _InvoiceHeldBillsChip(
                        count: heldBills.length,
                        onTap: () => HoldBillsPanel.show(
                          context,
                          cartSessionKey: cartSessionKey,
                        ),
                      ),
                    ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _dateFormat.format(now),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _timeFormat.format(now),
                  style: textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'Customer',
          style: textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        _CustomerMenu(
          parties: parties,
          selectedName: cart.customerName,
          onSelected: (name) {
            ref
                .read(posCartProvider(sessionKey: cartSessionKey).notifier)
                .setCustomerName(name);
          },
        ),
        parties.maybeWhen(
          data: (list) => SaleInvoicePartyLedgerChips(
            parties: list,
            customerName: cart.customerName,
          ),
          orElse: () => const SizedBox.shrink(),
        ),
        const SizedBox(height: AppSpacing.sm),
      ],
    );

    final invoiceLines = _SaleInvoiceItemsTable(
      cartSessionKey: cartSessionKey,
      textTheme: textTheme,
    );

    final invoiceFooter = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),
        _TotalRow(label: 'Total Items', value: '${cart.totalQty}'),
        _TotalRow(label: 'Sub Total', value: _money.format(cart.subtotal)),
        _TotalRow(
          label: 'Discount',
          value: _money.format(cart.totalDiscount + cart.billDiscountAmount),
        ),
        _TotalRow(label: 'Tax', value: _money.format(cart.totalTax)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Text(
                'Grand Total',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              _money.format(cart.totalPayable),
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: cart.items.isEmpty ? null : onHold,
                icon: const Icon(Icons.pause_circle_outline),
                label: const Text('Hold'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: cart.items.isEmpty ? null : onClear,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Clear'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: cart.items.isEmpty
              ? null
              : () => SaleScreenShareBillDialog.show(
                  context,
                  cartSessionKey: cartSessionKey,
                ),
          icon: const Icon(Icons.share_outlined, size: 18),
          label: const Text('Share Bill'),
          style: PosButtonStyles.primaryOutlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          onPressed: cart.items.isEmpty ? null : onPrint,
          icon: const Icon(Icons.print_outlined),
          label: const Text('Print'),
          style: PosButtonStyles.primaryOutlined,
        ),
        const SizedBox(height: AppSpacing.sm),
        FilledButton.icon(
          onPressed: cart.items.isEmpty || isCompleting ? null : onPay,
          icon: isCompleting
              ? const SizedBox(
                  width: AppSpacing.lg,
                  height: AppSpacing.lg,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.payments_outlined),
          label: Text(isCompleting ? 'Completing…' : 'Pay & Complete (F9)'),
        ),
      ],
    );

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: posCardBorder)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            invoiceHeader,
            Expanded(child: invoiceLines),
            invoiceFooter,
          ],
        ),
      ),
    );
  }
}

class _InvoiceHeldBillsChip extends StatelessWidget {
  const _InvoiceHeldBillsChip({
    required this.count,
    required this.onTap,
  });

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 bill on hold' : '$count bills on hold';

    return Tooltip(
      message: 'View held bills',
      child: Material(
        color: AppColors.background,
        borderRadius: AppRadius.smBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smBorder,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smBorder,
              border: Border.all(color: posCardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.pause_circle_outline,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerMenu extends ConsumerStatefulWidget {
  const _CustomerMenu({
    required this.parties,
    required this.selectedName,
    required this.onSelected,
  });

  final AsyncValue<List<PartyModel>> parties;
  final String? selectedName;
  final ValueChanged<String?> onSelected;

  @override
  ConsumerState<_CustomerMenu> createState() => _CustomerMenuState();
}

class _CustomerMenuState extends ConsumerState<_CustomerMenu> {
  final _link = LayerLink();
  final _fieldKey = GlobalKey();
  OverlayEntry? _overlay;
  double? _trackedWidth;

  @override
  void dispose() {
    _overlay?.remove();
    _overlay = null;
    super.dispose();
  }

  void _close() {
    _overlay?.remove();
    _overlay = null;
    _trackedWidth = null;
    if (mounted) setState(() {});
  }

  void _open() {
    if (_overlay != null) return;
    _overlay = OverlayEntry(builder: (overlayContext) => _buildOverlay());
    Overlay.of(context).insert(_overlay!);
    setState(() {});
  }

  void _toggle() {
    if (_overlay != null) {
      _close();
    } else {
      _open();
    }
  }

  void _select(String? name) {
    if (isWalkInPartyName(name ?? '')) {
      widget.onSelected(null);
    } else {
      widget.onSelected(name);
    }
    _close();
  }

  Future<void> _openAddPartyDialog() async {
    _close();
    final result = await showAddPartyDialog(context);
    if (!mounted || result == null) return;

    ref.invalidate(partyPickerListProvider);
    ref.invalidate(partiesListProvider);
    widget.onSelected(result.partyName);
  }

  ({double width, double maxHeight, bool openAbove})? _panelMetrics() {
    final fieldContext = _fieldKey.currentContext;
    final box = fieldContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize || !box.attached) return null;

    final origin = box.localToGlobal(Offset.zero);
    final media = MediaQuery.of(fieldContext!);
    final spaceBelow =
        media.size.height - origin.dy - box.size.height - media.padding.bottom;
    final spaceAbove = origin.dy - media.padding.top;
    final openAbove = spaceBelow < spaceAbove;
    final available = (openAbove ? spaceAbove : spaceBelow) - AppSpacing.xs;

    return (
      width: box.size.width,
      maxHeight: available > 0 ? available : 0,
      openAbove: openAbove,
    );
  }

  Widget _buildOverlay() {
    final metrics = _panelMetrics();
    if (metrics == null || metrics.maxHeight <= 0) {
      return const SizedBox.shrink();
    }

    final businessId = ref.read(currentBusinessProvider)?.id;
    final customers = widget.parties.maybeWhen(
      data: (list) => customerPartiesExcludingWalkIn(
        list,
        businessId: businessId,
      ),
      orElse: () => const <PartyModel>[],
    );
    final selected = widget.selectedName?.trim();

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: _close,
          ),
        ),
        CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          targetAnchor: metrics.openAbove
              ? Alignment.topLeft
              : Alignment.bottomLeft,
          followerAnchor: metrics.openAbove
              ? Alignment.bottomLeft
              : Alignment.topLeft,
          child: SizedBox(
            width: metrics.width,
            child: _CustomerPanel(
              maxHeight: metrics.maxHeight,
              customers: customers,
              selectedName: selected,
              loading: widget.parties.isLoading,
              onSelected: _select,
              onAddParty: _openAddPartyDialog,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(partyPickerListProvider, (_, _) {
      _overlay?.markNeedsBuild();
    });

    final label = isWalkInCartCustomerName(widget.selectedName)
        ? PosConstants.walkInCustomerLabel
        : widget.selectedName!.trim();
    final isOpen = _overlay != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (_overlay != null && _trackedWidth != constraints.maxWidth) {
          final width = constraints.maxWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted || _overlay == null || _trackedWidth == width) return;
            _trackedWidth = width;
            _overlay?.markNeedsBuild();
          });
        }
        return CompositedTransformTarget(
          link: _link,
          child: InkWell(
            key: _fieldKey,
            onTap: _toggle,
            borderRadius: AppRadius.mdBorder,
            child: InputDecorator(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: isOpen
                    ? IconButton(
                        tooltip: 'Close',
                        onPressed: _close,
                        icon: const Icon(Icons.close),
                      )
                    : const Icon(Icons.expand_more),
                border: OutlineInputBorder(borderRadius: AppRadius.mdBorder),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.mdBorder,
                  borderSide: const BorderSide(color: posCardBorder),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CustomerPanel extends StatelessWidget {
  const _CustomerPanel({
    required this.maxHeight,
    required this.customers,
    required this.selectedName,
    required this.loading,
    required this.onSelected,
    required this.onAddParty,
  });

  final double maxHeight;
  final List<PartyModel> customers;
  final String? selectedName;
  final bool loading;
  final ValueChanged<String?> onSelected;
  final VoidCallback onAddParty;

  @override
  Widget build(BuildContext context) {
    final currentName = selectedName?.trim();
    final walkInSelected = isWalkInCartCustomerName(selectedName);

    return Material(
      color: AppColors.surface,
      elevation: 6,
      shadowColor: Colors.black26,
      borderRadius: AppRadius.mdBorder,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdBorder,
            border: Border.all(color: posCardBorder),
          ),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                _AddPartyTile(onTap: onAddParty),
                const Divider(height: 1, color: posCardBorder),
                _CustomerTile(
                  label: PosConstants.walkInCustomerLabel,
                  selected: walkInSelected,
                  onTap: () => onSelected(null),
                ),
                for (final party in customers)
                  _CustomerTile(
                    label: party.name,
                    selected: currentName == party.name,
                    onTap: () => onSelected(party.name),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _AddPartyTile extends StatelessWidget {
  const _AddPartyTile({required this.onTap});

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
            const Icon(Icons.add, size: 18, color: AppColors.primary),
            const SizedBox(width: AppSpacing.sm),
            Text(
              'Add New Party',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomerTile extends StatelessWidget {
  const _CustomerTile({
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
      child: ColoredBox(
        color: selected ? AppColors.tabActiveTint : Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _SaleInvoiceItemsTable extends ConsumerStatefulWidget {
  const _SaleInvoiceItemsTable({
    required this.cartSessionKey,
    required this.textTheme,
  });

  final String cartSessionKey;
  final TextTheme textTheme;

  @override
  ConsumerState<_SaleInvoiceItemsTable> createState() =>
      _SaleInvoiceItemsTableState();
}

class _SaleInvoiceItemsTableState extends ConsumerState<_SaleInvoiceItemsTable> {
  final Set<String> _selectedItemIds = {};

  @override
  void didUpdateWidget(covariant _SaleInvoiceItemsTable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cartSessionKey != widget.cartSessionKey) {
      _selectedItemIds.clear();
    }
  }

  bool? _selectAllValue(List<CartItem> items) {
    if (items.isEmpty) return false;
    var selectedCount = 0;
    for (final line in items) {
      if (_selectedItemIds.contains(line.item.id)) {
        selectedCount += 1;
      }
    }
    if (selectedCount == 0) return false;
    if (selectedCount == items.length) return true;
    return null;
  }

  void _toggleSelectAll(List<CartItem> items) {
    final value = _selectAllValue(items);
    setState(() {
      if (value == true) {
        _selectedItemIds.clear();
      } else {
        _selectedItemIds
          ..clear()
          ..addAll(items.map((line) => line.item.id));
      }
    });
  }

  void _toggleLine(String itemId, bool? selected) {
    setState(() {
      if (selected == true) {
        _selectedItemIds.add(itemId);
      } else {
        _selectedItemIds.remove(itemId);
      }
    });
  }

  List<CartItem> _selectedLines(List<CartItem> items) => items
      .where((line) => _selectedItemIds.contains(line.item.id))
      .toList();

  Future<void> _onColumnMenuSelected(
    BuildContext context,
    _InvoiceItemsColumnMenuAction action,
    List<CartItem> items,
  ) async {
    final selectedLines = _selectedLines(items);
    if (selectedLines.isEmpty) return;

    switch (action) {
      case _InvoiceItemsColumnMenuAction.alternativeItems:
        await SaleScreenAlternativeReplaceDialog.show(
          context,
          cartSessionKey: widget.cartSessionKey,
          lines: selectedLines,
        );
      case _InvoiceItemsColumnMenuAction.priceIncrement:
        await SaleScreenPriceIncrementDialog.show(
          context,
          cartSessionKey: widget.cartSessionKey,
          lines: selectedLines,
        );
    }

    if (!context.mounted) return;
    setState(_selectedItemIds.clear);
  }

  @override
  Widget build(BuildContext context) {
    final items =
        ref.watch(posCartProvider(sessionKey: widget.cartSessionKey)).items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Divider(height: 1, color: posCardBorder),
        _LineHeader(
          textTheme: widget.textTheme,
          selectAllValue: _selectAllValue(items),
          onSelectAllChanged: items.isEmpty
              ? null
              : (_) => _toggleSelectAll(items),
          hasSelectedLines: _selectedItemIds.isNotEmpty,
          onColumnMenuSelected: (action) =>
              _onColumnMenuSelected(context, action, items),
        ),
        const Divider(height: 1, color: posCardBorder),
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.lg,
                    ),
                    child: Text(
                      'Search a product and press Enter',
                      style: PosStyles.emptyStateStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, color: posCardBorder),
                  itemBuilder: (context, index) {
                    final line = items[index];
                    return _InvoiceLine(
                      key: ValueKey(line.item.id),
                      cartSessionKey: widget.cartSessionKey,
                      line: line,
                      isSelected: _selectedItemIds.contains(line.item.id),
                      onSelectionChanged: (selected) =>
                          _toggleLine(line.item.id, selected),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

enum _InvoiceItemsColumnMenuAction {
  alternativeItems,
  priceIncrement,
}

class _LineHeader extends StatelessWidget {
  const _LineHeader({
    required this.textTheme,
    required this.selectAllValue,
    required this.hasSelectedLines,
    required this.onColumnMenuSelected,
    this.onSelectAllChanged,
  });

  final TextTheme textTheme;
  final bool? selectAllValue;
  final bool hasSelectedLines;
  final ValueChanged<_InvoiceItemsColumnMenuAction> onColumnMenuSelected;
  final ValueChanged<bool?>? onSelectAllChanged;

  @override
  Widget build(BuildContext context) {
    final style = textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      fontWeight: FontWeight.w700,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: _lineSelectColumnWidth,
            child: Tooltip(
              message: 'Select all',
              child: Checkbox(
                tristate: true,
                value: selectAllValue,
                onChanged: onSelectAllChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
          Expanded(flex: 5, child: Text('Item', style: style)),
          Expanded(flex: 2, child: Text('Qty', style: style)),
          Expanded(
            flex: 2,
            child: Text('Rate', style: style, textAlign: TextAlign.end),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text('Amount', style: style, textAlign: TextAlign.end),
            ),
          ),
          SizedBox(
            width: _lineMenuColumnWidth,
            child: hasSelectedLines
                ? PopupMenuButton<_InvoiceItemsColumnMenuAction>(
                    tooltip: 'Column actions',
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.more_vert,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: _lineMenuColumnWidth,
                      minHeight: 28,
                    ),
                    onSelected: onColumnMenuSelected,
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: _InvoiceItemsColumnMenuAction.alternativeItems,
                        child: Text('Alternative items'),
                      ),
                      const PopupMenuItem(
                        value: _InvoiceItemsColumnMenuAction.priceIncrement,
                        child: Text('Price increment'),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _InvoiceLine extends ConsumerWidget {
  const _InvoiceLine({
    required this.cartSessionKey,
    required this.line,
    required this.isSelected,
    required this.onSelectionChanged,
    super.key,
  });

  final String cartSessionKey;
  final CartItem line;
  final bool isSelected;
  final ValueChanged<bool?> onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier =
        ref.read(posCartProvider(sessionKey: cartSessionKey).notifier);
    final textTheme = Theme.of(context).textTheme;
    final detail = [
      if (line.item.brandName?.trim().isNotEmpty == true) line.item.brandName!,
      line.item.sku,
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: _lineSelectColumnWidth,
            child: Checkbox(
              value: isSelected,
              onChanged: onSelectionChanged,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ),
          Expanded(
            flex: 5,
            child: Row(
              children: [
                PosItemThumbnail(item: line.item, size: AppSpacing.xxxl),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        line.item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: _InvoiceLineQuantityField(
              itemId: line.item.id,
              quantity: line.quantity,
              onDecrease: () => notifier.updateQuantity(
                line.item.id,
                line.quantity - 1,
              ),
              onIncrease: () => notifier.updateQuantity(
                line.item.id,
                line.quantity + 1,
              ),
              onCommit: (qty) => notifier.updateQuantity(line.item.id, qty),
            ),
          ),
          Expanded(
            flex: 2,
            child: _InvoiceLineRateField(
              rate: line.unitPrice,
              onCommit: (rate) =>
                  notifier.updateUnitPrice(line.item.id, rate),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              _money.format(line.lineTotal),
              textAlign: TextAlign.end,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: _lineMenuColumnWidth),
        ],
      ),
    );
  }
}

class _InvoiceLineQuantityField extends ConsumerStatefulWidget {
  const _InvoiceLineQuantityField({
    required this.itemId,
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    required this.onCommit,
  });

  final String itemId;
  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final ValueChanged<int> onCommit;

  @override
  ConsumerState<_InvoiceLineQuantityField> createState() =>
      _InvoiceLineQuantityFieldState();
}

class _InvoiceLineQuantityFieldState
    extends ConsumerState<_InvoiceLineQuantityField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _applyFocusRequestIfNeeded();
    });
  }

  @override
  void didUpdateWidget(covariant _InvoiceLineQuantityField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity && !_focusNode.hasFocus) {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    final parsed = int.tryParse(_controller.text.trim());
    if (parsed == null || parsed <= 0) {
      _controller.text = '${widget.quantity}';
      return;
    }
    if (parsed != widget.quantity) {
      widget.onCommit(parsed);
    }
  }

  void _focusAndSelectAll() {
    if (!_focusNode.canRequestFocus) return;
    FocusScope.of(context).requestFocus(_focusNode);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_focusNode.hasFocus) return;
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    });
  }

  void _applyFocusRequestIfNeeded() {
    if (!mounted) return;
    final pending = ref.read(saleInvoiceQuantityFocusItemIdProvider);
    if (pending != widget.itemId) return;
    _controller.text = '${widget.quantity}';
    _focusAndSelectAll();
    ref.read(saleInvoiceQuantityFocusItemIdProvider.notifier).clear();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(saleInvoiceQuantityFocusItemIdProvider, (
      previous,
      next,
    ) {
      if (next != widget.itemId) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFocusRequestIfNeeded();
      });
    });

    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SaleInvoiceQtyButton(icon: Icons.remove, onTap: widget.onDecrease),
          SizedBox(
            width: 40,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              style: textStyle,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.smBorder,
                  borderSide: const BorderSide(color: posCardBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smBorder,
                  borderSide: const BorderSide(color: posCardBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.smBorder,
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
              onSubmitted: (_) => _commit(),
            ),
          ),
          _SaleInvoiceQtyButton(icon: Icons.add, onTap: widget.onIncrease),
        ],
      ),
    );
  }
}

class _InvoiceLineRateField extends StatefulWidget {
  const _InvoiceLineRateField({
    required this.rate,
    required this.onCommit,
  });

  final double rate;
  final ValueChanged<double> onCommit;

  @override
  State<_InvoiceLineRateField> createState() => _InvoiceLineRateFieldState();
}

class _InvoiceLineRateFieldState extends State<_InvoiceLineRateField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  String _formatRate(double rate) =>
      SalePriceInput.format(rate, zeroValue: '0');

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: _formatRate(widget.rate),
    );
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant _InvoiceLineRateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rate != widget.rate && !_focusNode.hasFocus) {
      _controller.text = _formatRate(widget.rate);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      _commit();
    }
  }

  void _commit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty && widget.rate != 0) {
      _controller.text = _formatRate(widget.rate);
      return;
    }
    final parsed = SalePriceInput.parse(trimmed);
    if (parsed < 0) {
      _controller.text = _formatRate(widget.rate);
      return;
    }
    if ((parsed - widget.rate).abs() > 0.0001) {
      widget.onCommit(parsed);
    } else {
      _controller.text = _formatRate(widget.rate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 72,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          keyboardType: SalePriceInput.keyboardType,
          inputFormatters: SalePriceInput.formatters,
          textAlign: TextAlign.end,
          style: textStyle,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 6,
              vertical: 6,
            ),
            prefixText: '₹',
            prefixStyle: textStyle,
            border: OutlineInputBorder(
              borderRadius: AppRadius.smBorder,
              borderSide: const BorderSide(color: posCardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBorder,
              borderSide: const BorderSide(color: posCardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AppRadius.smBorder,
              borderSide: const BorderSide(color: AppColors.primary),
            ),
          ),
          onSubmitted: (_) => _commit(),
        ),
      ),
    );
  }
}

class _SaleInvoiceQtyButton extends StatelessWidget {
  const _SaleInvoiceQtyButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.smBorder,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: posCardBorder),
          borderRadius: AppRadius.smBorder,
        ),
        child: Icon(icon, size: 14, color: AppColors.textSecondary),
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: AppColors.textSecondary,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            value,
            style: style?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
