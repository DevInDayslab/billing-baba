import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/purchases/application/expenses_provider.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
import 'package:billing_baba/features/purchases/presentation/desktop/widgets/add_expense_item_dialog.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _maxDropdownItems = 150;

class ExpenseItemNameAutocompleteField extends ConsumerStatefulWidget {
  const ExpenseItemNameAutocompleteField({
    required this.value,
    required this.onChanged,
    required this.onItemSelected,
    super.key,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final ValueChanged<ExpenseCatalogItemModel> onItemSelected;

  @override
  ConsumerState<ExpenseItemNameAutocompleteField> createState() =>
      _ExpenseItemNameAutocompleteFieldState();
}

class _ExpenseItemNameAutocompleteFieldState
    extends ConsumerState<ExpenseItemNameAutocompleteField> {
  final LayerLink _layerLink = LayerLink();
  final FocusNode _focusNode = FocusNode();
  OverlayEntry? _overlayEntry;
  late final TextEditingController _controller;

  static final _priceFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(ExpenseItemNameAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && widget.value != _controller.text) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _controller.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChange() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    }
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<ExpenseCatalogItemModel> _filteredItems(
    List<ExpenseCatalogItemModel> items,
  ) {
    final query = _controller.text.trim().toLowerCase();
    if (query.isEmpty) return items.take(_maxDropdownItems).toList();
    return items
        .where((item) => item.name.toLowerCase().contains(query))
        .take(_maxDropdownItems)
        .toList();
  }

  Future<void> _openAddItemDialog() async {
    _removeOverlay();
    final created = await showAddExpenseItemDialog(context);
    if (!mounted || created == null) return;
    _controller.text = created.name;
    widget.onChanged(created.name);
    widget.onItemSelected(created);
    _focusNode.unfocus();
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    final triggerWidth = renderBox?.size.width ?? 280;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final catalogAsync = ref.watch(expenseCatalogItemsProvider);
        final panelWidth = triggerWidth < 360 ? 360.0 : triggerWidth;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _removeOverlay();
                  _focusNode.unfocus();
                },
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 38),
              child: Material(
                elevation: 4,
                shadowColor: Colors.black26,
                borderRadius: AppRadius.mdBorder,
                clipBehavior: Clip.antiAlias,
                color: AppColors.surface,
                child: SizedBox(
                  width: panelWidth,
                  child: catalogAsync.when(
                    loading: () => _buildItemsPanel(
                      panelWidth,
                      const [],
                      showLoadingHint: true,
                    ),
                    error: (_, _) => _buildItemsPanel(panelWidth, const []),
                    data: (items) => _buildItemsPanel(
                      panelWidth,
                      _filteredItems(items),
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

  Widget _buildItemsPanel(
    double panelWidth,
    List<ExpenseCatalogItemModel> filtered, {
    bool showLoadingHint = false,
  }) {
    return SizedBox(
      width: panelWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'ITEM',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  'PRICE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (showLoadingHint)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Loading items…',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          if (!showLoadingHint && filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'No expense items yet',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else if (!showLoadingHint)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 220),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final item = filtered[index];
                  return InkWell(
                    onTap: () {
                      _controller.text = item.name;
                      widget.onChanged(item.name);
                      widget.onItemSelected(item);
                      _removeOverlay();
                      _focusNode.unfocus();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.name,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          Text(
                            _priceFormat.format(item.price),
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(height: 1),
          TextButton(
            onPressed: _openAddItemDialog,
            child: const Text('+ Add Expense Item'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: _controller,
        focusNode: _focusNode,
        style: saleFieldTextStyle.copyWith(fontSize: 12),
        decoration: buildSaleFieldDecoration(
          hint: 'Item Name',
          compact: true,
        ),
        onChanged: (value) {
          widget.onChanged(value);
          _overlayEntry?.markNeedsBuild();
        },
        onTap: () {
          if (!_focusNode.hasFocus) {
            _focusNode.requestFocus();
          }
          _showOverlay();
        },
      ),
    );
  }
}
