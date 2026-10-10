import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/out_of_stock_dialog.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/models/pos_item.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_invoice_panel.dart';
import 'package:billing_baba/features/sale_screen/presentation/widgets/sale_product_pane.dart';
import 'package:billing_baba/shared/utils/output_error_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Keyboard-first counter: type a product, press Enter, keep typing.
class SaleScreenPage extends ConsumerStatefulWidget {
  const SaleScreenPage({super.key});

  @override
  ConsumerState<SaleScreenPage> createState() => _SaleScreenPageState();
}

class _SaleScreenPageState extends ConsumerState<SaleScreenPage> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  String _query = '';
  String? _categoryId;
  int _highlightIndex = 0;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<PosItem> get _results => ref.read(
    posFilteredCatalogProvider(
      searchQuery: _query,
      categoryId: _categoryId,
    ),
  );

  void _onQueryChanged(String value) {
    setState(() {
      _query = value;
      _highlightIndex = 0;
    });
  }

  void _clearQuery() {
    _searchController.clear();
    setState(() {
      _query = '';
      _highlightIndex = 0;
    });
    _searchFocus.requestFocus();
  }

  void _moveHighlight(int delta) {
    final count = _results.length;
    if (count == 0) return;
    setState(() {
      _highlightIndex = (_highlightIndex + delta) % count;
      if (_highlightIndex < 0) _highlightIndex += count;
    });
  }

  void _addHighlighted() {
    final items = _results;
    if (_query.trim().isEmpty || items.isEmpty) return;
    final index = _highlightIndex.clamp(0, items.length - 1);
    _addItem(items[index]);
  }

  void _addItem(PosItem item) {
    if (item.isOutOfStock) {
      showDialog<void>(
        context: context,
        builder: (dialogContext) => OutOfStockDialog(
          itemId: item.id,
          itemName: item.name,
          onSelectAlternative: (alternative) async {
            ref
                .read(posCartProvider.notifier)
                .addItem(
                  PosItem(
                    id: alternative.id,
                    name: alternative.name,
                    sku: alternative.barcode ?? '',
                    categoryName: alternative.categoryName ?? item.categoryName,
                    price: alternative.salePrice,
                    stock: alternative.stockQuantity.toInt(),
                    unit: item.unit,
                    brandName: item.brandName,
                  ),
                );
            _clearQuery();
          },
          onContinueAnyway: () async {
            ref.read(posCartProvider.notifier).addItem(item);
            _clearQuery();
          },
        ),
      );
      return;
    }

    ref.read(posCartProvider.notifier).addItem(item);
    _clearQuery();
  }

  Future<void> _holdBill() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      _showMessage('Add an item before holding the bill');
      return;
    }
    await ref.read(posCartProvider.notifier).holdBill();
    if (!mounted) return;
    _showMessage('Bill held');
    _searchFocus.requestFocus();
  }

  void _clearBill() {
    final notifier = ref.read(posCartProvider.notifier);
    notifier.clearCart();
    notifier.setCustomerName(null);
    _searchFocus.requestFocus();
  }

  Future<void> _printBill() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      _showMessage('Add items before printing');
      return;
    }

    final preview = PosSale(
      id: 'PREVIEW',
      docNumber: 'Bill Preview',
      completedAt: DateTime.now(),
      totalAmount: cart.subtotal,
      taxAmount: cart.totalTax,
      finalAmount: cart.totalPayable,
      itemCount: cart.totalQty,
      customerName: cart.customerName,
      payments: cart.payments,
      items: [
        for (final line in cart.items)
          PosSaleLineItem(
            name: line.item.name,
            quantity: line.quantity,
            lineTotal: line.lineTotal,
            itemId: line.item.id,
            unit: line.item.unit,
            unitPrice: line.item.price,
          ),
      ],
    );

    try {
      await ref
          .read(posReceiptPrinterProvider)
          .preview(
            context: context,
            sale: preview,
            ref: ref,
          );
    } catch (error) {
      if (!mounted) return;
      _showMessage(OutputErrorMapper.printMessage(error));
    } finally {
      _searchFocus.requestFocus();
    }
  }

  Future<void> _payAndComplete() async {
    if (_isCompleting) return;
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      _showMessage('Add at least one item');
      _searchFocus.requestFocus();
      return;
    }

    setState(() => _isCompleting = true);
    try {
      final sale = await ref.read(posCartProvider.notifier).completeSale();
      if (!mounted) return;
      ref.read(posSalesListProvider.notifier).addSale(sale);
      _showMessage('Sale ${sale.docNumber} completed');
    } on PosRepositoryException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (error) {
      if (!mounted) return;
      _showMessage(OfflineUiMessages.messageFor(error));
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
        _searchFocus.requestFocus();
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.f9): () {
          unawaited(_payAndComplete());
        },
      },
      child: Focus(
        autofocus: true,
        child: ColoredBox(
          color: AppColors.background,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final stackInvoice = constraints.maxWidth < PosBreakpoints.tablet;
              final catalog = SaleProductPane(
                query: _query,
                categoryId: _categoryId,
                highlightIndex: _highlightIndex,
                searchController: _searchController,
                searchFocus: _searchFocus,
                onQueryChanged: _onQueryChanged,
                onMoveHighlight: _moveHighlight,
                onSubmitSearch: _addHighlighted,
                onClearQuery: _clearQuery,
                onCategoryChanged: (categoryId) {
                  setState(() {
                    _categoryId = categoryId;
                    _highlightIndex = 0;
                  });
                },
                onItemSelected: _addItem,
              );
              final invoice = SaleInvoicePanel(
                isCompleting: _isCompleting,
                onHold: () => unawaited(_holdBill()),
                onClear: _clearBill,
                onPrint: () => unawaited(_printBill()),
                onPay: () => unawaited(_payAndComplete()),
              );

              if (stackInvoice) {
                return Column(
                  children: [
                    Expanded(flex: 3, child: catalog),
                    Expanded(flex: 2, child: invoice),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(flex: 3, child: catalog),
                  Expanded(flex: 2, child: invoice),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
