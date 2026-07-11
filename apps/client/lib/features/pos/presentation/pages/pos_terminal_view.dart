import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/utils/debouncer.dart';
import 'package:billing_baba/features/pos/models/pos_sale.dart';
import 'package:billing_baba/features/pos/models/pos_sale_line_item.dart';
import 'package:billing_baba/features/pos/presentation/widgets/cart_panel.dart';
import 'package:billing_baba/features/pos/presentation/widgets/hold_bills_panel.dart';
import 'package:billing_baba/features/pos/presentation/widgets/item_grid.dart';
import 'package:billing_baba/features/pos/presentation/widgets/payment_panel.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_panel.dart';
import 'package:billing_baba/features/pos/presentation/widgets/pos_styles.dart';
import 'package:billing_baba/features/pos/providers/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_items_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_sales_list_provider.dart';
import 'package:billing_baba/features/pos/providers/pos_session_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Full-screen POS billing terminal.
class PosTerminalView extends ConsumerStatefulWidget {
  const PosTerminalView({super.key});

  @override
  ConsumerState<PosTerminalView> createState() => _PosTerminalViewState();
}

class _PosTerminalViewState extends ConsumerState<PosTerminalView> {
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

  void _holdBill() {
    ref.read(posCartProvider.notifier).holdBill();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bill held successfully')),
    );
  }

  Future<void> _completeSale() async {
    final cart = ref.read(posCartProvider);
    if (cart.items.isEmpty || cart.totalPayable <= 0) return;

    try {
      final saleId = await ref.read(posCartProvider.notifier).completeSale();
      if (!mounted) return;

      ref.read(posSalesListProvider.notifier).addSale(
            PosSale(
              id: saleId,
              billNo: saleId,
              completedAt: DateTime.now(),
              amount: cart.totalPayable,
              itemCount: cart.totalQty,
              customerName: cart.customerName,
              payments: List.from(cart.payments),
              items: cart.items
                  .map(
                    (line) => PosSaleLineItem(
                      name: line.item.name,
                      quantity: line.quantity,
                      lineTotal: line.lineTotal,
                    ),
                  )
                  .toList(),
            ),
          );

      ref.read(posSessionProvider.notifier).closeTerminal();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale completed! ID: $saleId')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to complete sale: $error')),
      );
    }
  }

  void _onSearchChanged(String value) {
    _searchDebouncer.run(() {
      ref.read(posItemSearchQueryProvider.notifier).setQuery(value);
    });
  }

  void _exitTerminal() {
    ref.read(posSessionProvider.notifier).closeTerminal();
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final isAltS = event.logicalKey == LogicalKeyboardKey.keyS &&
        HardwareKeyboard.instance.isAltPressed;
    if (isAltS) {
      _searchFocusNode.requestFocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.f7) {
      _holdBill();
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
    final heldCount = ref.watch(posCartProvider).heldBills.length;
    final cartItemCount = ref.watch(posCartProvider).totalItems;

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKeyEvent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PosToolbar(
            heldCount: heldCount,
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
                final isTablet = width >= PosBreakpoints.mobile &&
                    width < PosBreakpoints.tablet;
                final isCompact = width < PosBreakpoints.laptop;

                final itemGrid = PosPanel(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: const ItemGrid(),
                );
                final cartPanel = CartPanel(onHoldBill: _holdBill);
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
                              Expanded(flex: 4, child: itemGrid),
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
                      Expanded(flex: 4, child: itemGrid),
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
    required this.searchController,
    required this.searchFocusNode,
    required this.onSearchChanged,
    required this.onHoldBillsTap,
    required this.onNewSale,
    required this.onBack,
  });

  final int heldCount;
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
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
                              const Text('|', style: PosStyles.shortcutHintStyle),
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
                    const Text('Show Hints', style: PosStyles.shortcutHintStyle),
                  ],
                ),
        );
      },
    );
  }
}
