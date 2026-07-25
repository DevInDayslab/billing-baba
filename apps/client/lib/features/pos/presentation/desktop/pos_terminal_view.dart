import 'dart:async';

import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/pos/application/pos_receipt_printer.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/pos_exceptions.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/cart_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/hold_bills_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/item_grid.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/payment_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/receipt_view_widget.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/application/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/application/pos_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen POS billing terminal.
class DesktopPosTerminalView extends ConsumerStatefulWidget {
  const DesktopPosTerminalView({super.key});

  @override
  ConsumerState<DesktopPosTerminalView> createState() => _PosTerminalViewState();
}

class _PosTerminalViewState extends ConsumerState<DesktopPosTerminalView> {
  final _focusNode = FocusNode();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _searchDebouncer = Debouncer();
  int _mobileTabIndex = 0;
  bool _showShortcutHints = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _searchDebouncer.dispose();
    super.dispose();
  }

  Future<void> _printCurrentBill() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete sale first to print')),
      );
      return;
    }

    final previewSale = PosSale(
      id: 'PREVIEW',
      docNumber: 'Bill Preview',
      completedAt: DateTime.now(),
      totalAmount: cart.subtotal,
      taxAmount: cart.totalTax,
      finalAmount: cart.totalPayable,
      itemCount: cart.totalQty,
      customerName: cart.customerName,
      payments: cart.payments,
      items: cart.items
          .map(
            (item) => PosSaleLineItem(
              name: item.item.name,
              quantity: item.quantity,
              lineTotal: item.lineTotal,
              itemId: item.item.id,
              unit: item.item.unit,
              unitPrice: item.item.price,
            ),
          )
          .toList(),
    );

    try {
      await ref
          .read(posReceiptPrinterProvider)
          .preview(
            context: context,
            sale: previewSale,
            ref: ref,
          );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Print failed: $error')),
      );
    }
  }

  Future<void> _holdBill() async {
    await ref.read(posCartProvider.notifier).holdBill();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill held successfully')),
    );
  }

  Future<void> _completeSale() async {
    final session = ref.read(posSessionProvider);
    if (!session.hasActiveBackendSession) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('POS session not open. Please retry.')),
      );
      return;
    }

    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty || cart.totalPayable <= 0) return;

    final totalPaid = cart.payments.fold(0.0, (sum, p) => sum + p.amount);
    final totalPayable = cart.totalPayable;
    if (cart.payments.isNotEmpty && totalPaid < totalPayable) {
      // TODO(product): Support short POS payments with the same Official Due vs
      // Hidden Ledger prompt used in Payment-In and credit sale finalize flows.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment amount is less than total'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!mounted) return;
    unawaited(
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Expanded(child: Text('Creating sale...')),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final sale = await ref.read(posCartProvider.notifier).completeSale();
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      ref.read(posSalesListProvider.notifier).addSale(sale);
      await _showReceiptDialog(sale);
    } on PosRepositoryException catch (error) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 5),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete sale: $error')),
      );
    }
  }

  Future<void> _showReceiptDialog(PosSale sale) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: ReceiptViewWidget(sale: sale),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      ref.read(posItemSearchQueryProvider.notifier).setQuery(value);
    });
  }

  Future<void> _exitTerminal() async {
    await ref.read(posSessionProvider.notifier).closeTerminal();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isAltS =
        event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isAltPressed;
    if (isAltS) {
      _searchFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f7) {
      _holdBill();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f8) {
      unawaited(_printCurrentBill());
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f9) {
      _completeSale();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _exitTerminal();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(posSessionProvider);
    final heldCount = ref.watch(posCartProvider).heldBills.length;
    final cartItemCount = ref.watch(posCartProvider).totalItems;

    if (session.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (session.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Could not open POS session',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(session.errorMessage!),
              const SizedBox(height: AppSpacing.md),
              FilledButton(
                onPressed: () =>
                    ref.read(posSessionProvider.notifier).openTerminal(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PosToolbar(
            heldCount: heldCount,
            sessionLabel: session.backendSession?.id.substring(0, 8),
            searchController: _searchController,
            searchFocusNode: _searchFocusNode,
            onSearchChanged: _onSearchChanged,
            onHoldBillsTap: () => HoldBillsPanel.show(context),
            onNewSale: () => ref.read(posCartProvider.notifier).clearCart(),
            onBack: _exitTerminal,
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isMobile = width < PosBreakpoints.mobile;
                final isTablet =
                    width >= PosBreakpoints.mobile &&
                    width < PosBreakpoints.tablet;
                final isCompact = width < PosBreakpoints.laptop;

                const itemGrid = PosPanel(
                  padding: EdgeInsets.all(AppSpacing.sm),
                  child: ItemGrid(),
                );
                final cartPanel = CartPanel(
                  onHoldBill: _holdBill,
                  onPrint: _printCurrentBill,
                );
                final paymentPanel = PaymentPanel(
                  onCompleteSale: _completeSale,
                );

                if (isMobile) {
                  return _MobilePosLayout(
                    tabIndex: _mobileTabIndex,
                    cartItemCount: cartItemCount,
                    onTabChanged: (index) =>
                        setState(() => _mobileTabIndex = index),
                    itemGrid: itemGrid,
                    cartPanel: cartPanel,
                    paymentPanel: paymentPanel,
                  );
                }

                final gap = isCompact ? AppSpacing.sm : AppSpacing.md;
                final padding = EdgeInsets.fromLTRB(
                  isCompact ? AppSpacing.sm : AppSpacing.md,
                  AppSpacing.sm,
                  isCompact ? AppSpacing.sm : AppSpacing.md,
                  isCompact ? AppSpacing.sm : AppSpacing.md,
                );

                if (isTablet) {
                  return Padding(
                    padding: padding,
                    child: Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Expanded(flex: 4, child: itemGrid),
                              SizedBox(width: gap),
                              Expanded(flex: 5, child: cartPanel),
                            ],
                          ),
                        ),
                        SizedBox(height: gap),
                        Expanded(
                          flex: 2,
                          child: paymentPanel,
                        ),
                      ],
                    ),
                  );
                }

                final paymentWidth = isCompact ? 280.0 : 320.0;
                return Padding(
                  padding: padding,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Expanded(flex: 4, child: itemGrid),
                      SizedBox(width: gap),
                      Expanded(flex: 5, child: cartPanel),
                      SizedBox(width: gap),
                      SizedBox(
                        width: paymentWidth,
                        child: paymentPanel,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (_showShortcutHints)
            _ShortcutHintsBar(
              onToggleHints: () =>
                  setState(() => _showShortcutHints = !_showShortcutHints),
            ),
        ],
      ),
    );
  }
}

class _MobilePosLayout extends StatelessWidget {
  const _MobilePosLayout({
    required this.tabIndex,
    required this.cartItemCount,
    required this.onTabChanged,
    required this.itemGrid,
    required this.cartPanel,
    required this.paymentPanel,
  });

  final int tabIndex;
  final int cartItemCount;
  final ValueChanged<int> onTabChanged;
  final Widget itemGrid;
  final Widget cartPanel;
  final Widget paymentPanel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: IndexedStack(
              index: tabIndex,
              children: [
                itemGrid,
                cartPanel,
                paymentPanel,
              ],
            ),
          ),
        ),
        NavigationBar(
          selectedIndex: tabIndex,
          onDestinationSelected: onTabChanged,
          height: 64,
          indicatorColor: posSelectedBackground,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view),
              label: 'Products',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text('$cartItemCount'),
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.receipt_long_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: cartItemCount > 0,
                label: Text('$cartItemCount'),
                backgroundColor: colorScheme.primary,
                child: const Icon(Icons.receipt_long),
              ),
              label: 'Bill',
            ),
            const NavigationDestination(
              icon: Icon(Icons.payment_outlined),
              selectedIcon: Icon(Icons.payment),
              label: 'Checkout',
            ),
          ],
        ),
      ],
    );
  }
}

class _PosToolbar extends StatelessWidget {
  const _PosToolbar({
    required this.heldCount,
    required this.sessionLabel,
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onHoldBillsTap,
    required this.onNewSale,
    required this.onBack,
  });

  final int heldCount;
  final String? sessionLabel;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onHoldBillsTap;
  final VoidCallback onNewSale;
  final VoidCallback onBack;

  static const _barHeight = 60.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < PosBreakpoints.mobile;
        final isCompact = constraints.maxWidth < PosBreakpoints.laptop;

        return Container(
          height: _barHeight,
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? AppSpacing.sm : AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: posCardBorder)),
          ),
          child: isNarrow
              ? Row(
                  children: [
                    _ToolbarIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Back to list',
                      onPressed: onBack,
                    ),
                    Expanded(
                      child: _PosSearchField(
                        controller: searchController,
                        focusNode: searchFocusNode,
                        onChanged: onSearchChanged,
                        compact: true,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ToolbarIconButton(
                      icon: Icons.pause_circle_outline,
                      tooltip: 'Hold Bills',
                      onPressed: onHoldBillsTap,
                    ),
                    FilledButton(
                      onPressed: onNewSale,
                      style: PosButtonStyles.primaryFilled.copyWith(
                        padding: const WidgetStatePropertyAll(
                          EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                      child: const Icon(Icons.add, size: 20),
                    ),
                  ],
                )
              : Row(
                  children: [
                    _ToolbarIconButton(
                      icon: Icons.arrow_back,
                      tooltip: 'Back to list',
                      onPressed: onBack,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    if (sessionLabel != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: AppRadius.smBorder,
                          border: Border.all(color: posCardBorder),
                        ),
                        child: Text(
                          'Session ${sessionLabel!}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Expanded(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            minWidth: 280,
                            maxWidth: 560,
                          ),
                          child: _PosSearchField(
                            controller: searchController,
                            focusNode: searchFocusNode,
                            onChanged: onSearchChanged,
                            compact: isCompact,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: onHoldBillsTap,
                      style: PosButtonStyles.primaryOutlined,
                      icon: const Icon(Icons.pause_circle_outline, size: 18),
                      label: Text(
                        isCompact
                            ? 'Hold ($heldCount)'
                            : 'Hold Bills ($heldCount)',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton.icon(
                      onPressed: onNewSale,
                      style: PosButtonStyles.primaryFilled,
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('New Sale'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    _ToolbarIconButton(
                      icon: Icons.notifications_outlined,
                      tooltip: 'Notifications',
                      badge: 3,
                      onPressed: () {},
                    ),
                    _ToolbarIconButton(
                      icon: Icons.settings_outlined,
                      tooltip: 'Settings',
                      onPressed: () {},
                    ),
                    _ToolbarIconButton(
                      icon: Icons.open_in_full,
                      tooltip: 'Fullscreen',
                      onPressed: () {},
                    ),
                  ],
                ),
        );
      },
    );
  }
}

class _PosSearchField extends StatelessWidget {
  const _PosSearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.compact = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: compact
            ? 'Search items...'
            : 'Search items or scan barcode (Alt + S)',
        hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 13),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: posCardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: posCardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.mdBorder,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        isDense: true,
        prefixIcon: const Icon(
          Icons.qr_code_scanner_outlined,
          size: 20,
          color: AppColors.textSecondary,
        ),
        suffixIcon: compact
            ? const Icon(Icons.search, size: 18, color: AppColors.textSecondary)
            : Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.smBorder,
                        border: Border.all(color: posCardBorder),
                      ),
                      child: const Text(
                        'Alt + S',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        suffixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}

class _ToolbarIconButton extends StatelessWidget {
  const _ToolbarIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badge,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int? badge;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, size: 20, color: AppColors.textSecondary);

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: badge != null
          ? Badge(
              label: Text('$badge'),
              backgroundColor: AppColors.error,
              child: iconWidget,
            )
          : iconWidget,
    );
  }
}

class _ShortcutHintsBar extends StatelessWidget {
  const _ShortcutHintsBar({required this.onToggleHints});

  final VoidCallback onToggleHints;

  @override
  Widget build(BuildContext context) {
    const hints = [
      'F3: Search',
      'F7: Hold Bill',
      'F8: Print',
      'F9: Complete Sale',
      'Esc: Back to list',
      'Alt+S: Search',
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < PosBreakpoints.tablet;

        return Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: posCardBorder)),
          ),
          child: isNarrow
              ? Center(
                  child: TextButton.icon(
                    onPressed: onToggleHints,
                    icon: const Icon(Icons.keyboard, size: 16),
                    label: const Text('Hide shortcuts'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      textStyle: PosStyles.shortcutHintStyle,
                    ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppSpacing.xs,
                        runSpacing: AppSpacing.xs,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          for (var i = 0; i < hints.length; i++) ...[
                            if (i > 0)
                              const Text(
                                '|',
                                style: PosStyles.shortcutHintStyle,
                              ),
                            Text(hints[i], style: PosStyles.shortcutHintStyle),
                          ],
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        textStyle: PosStyles.shortcutHintStyle,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Keyboard Shortcuts'),
                    ),
                    Checkbox(
                      value: true,
                      onChanged: (_) => onToggleHints(),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                      activeColor: AppColors.primary,
                    ),
                    const Text(
                      'Show Hints',
                      style: PosStyles.shortcutHintStyle,
                    ),
                  ],
                ),
        );
      },
    );
  }
}
