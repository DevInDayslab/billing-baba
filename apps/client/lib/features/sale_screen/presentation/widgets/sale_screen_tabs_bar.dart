import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/presentation/desktop/widgets/pos_sales_history_dialog.dart';
import 'package:billing_baba/features/sale_screen/application/sale_screen_tabs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _barBackground = Color(0xFFDEE1E6);
const _activeTabBackground = Color(0xFFFFFFFF);
const _inactiveTabBackground = Color(0xFFE3E5E8);
const _tabBorderColor = Color(0xFFC5C9CE);
const _tabMinWidth = 80.0;
const _tabMaxWidth = 200.0;
const _tabHeight = 34.0;
const _historyHeadWidth = 96.0;
const _trailingControlSize = 28.0;
const _trailingGap = 4.0;

/// Chrome-style tab strip for multiple sale-screen POS sessions (up to 10).
class SaleScreenTabsBar extends ConsumerWidget {
  const SaleScreenTabsBar({
    this.onMinimize,
    this.onFormClose,
    super.key,
  });

  final VoidCallback? onMinimize;
  final VoidCallback? onFormClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(saleScreenTabsProvider);
    final tabsNotifier = ref.read(saleScreenTabsProvider.notifier);
    final tabCount = tabsState.tabs.length;

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: _barBackground,
        border: Border(bottom: BorderSide(color: _tabBorderColor)),
      ),
      child: SizedBox(
        height: _tabHeight + 6,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, top: 6, right: 8),
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final available = constraints.maxWidth;
                    final tabWidth = _tabWidthFor(available, tabCount);

                    final tabsRow = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < tabCount; i++)
                          SizedBox(
                            width: tabWidth,
                            child: _SaleScreenTabChip(
                              label: tabsState.tabs[i].label,
                              isActive: i == tabsState.activeIndex,
                              showClose: tabCount > 1,
                              onTap: () => tabsNotifier.selectTab(i),
                              onClose: () => _closeTab(ref, tabsNotifier, i),
                            ),
                          ),
                      ],
                    );

                    final needsHorizontalScroll =
                        tabWidth * tabCount > available + 0.5;
                    if (needsHorizontalScroll) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        clipBehavior: Clip.hardEdge,
                        child: tabsRow,
                      );
                    }
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: tabsRow,
                    );
                  },
                ),
              ),
              const SizedBox(width: _trailingGap),
              _HistoryHeadButton(
                onTap: () => PosSalesHistoryDialog.show(context),
              ),
              if (tabsNotifier.canAddTab) ...[
                const SizedBox(width: _trailingGap),
                _AddTabButton(onTap: tabsNotifier.addTab),
              ],
              if (onMinimize != null) ...[
                const SizedBox(width: _trailingGap),
                _MinimizeFormButton(onTap: onMinimize!),
              ],
              if (onFormClose != null) ...[
                const SizedBox(width: _trailingGap),
                _CloseFormButton(onTap: onFormClose!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static double _tabWidthFor(double available, int tabCount) {
    if (tabCount <= 0) return _tabMaxWidth;
    final even = available / tabCount;
    if (even >= _tabMinWidth) {
      return even.clamp(_tabMinWidth, _tabMaxWidth);
    }
    if (even >= 48) return even;
    return _tabMinWidth;
  }

  void _closeTab(WidgetRef ref, SaleScreenTabs tabsNotifier, int index) {
    final tabsState = ref.read(saleScreenTabsProvider);
    if (index < 0 || index >= tabsState.tabs.length) return;
    final sessionKey = tabsState.tabs[index].sessionKey;
    ref.invalidate(posCartProvider(sessionKey: sessionKey));
    tabsNotifier.closeTab(index);
  }
}

class _SaleScreenTabChip extends StatefulWidget {
  const _SaleScreenTabChip({
    required this.label,
    required this.isActive,
    required this.showClose,
    required this.onTap,
    required this.onClose,
  });

  final String label;
  final bool isActive;
  final bool showClose;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  State<_SaleScreenTabChip> createState() => _SaleScreenTabChipState();
}

class _SaleScreenTabChipState extends State<_SaleScreenTabChip> {
  var _hovered = false;

  @override
  Widget build(BuildContext context) {
    final showCloseControl = widget.showClose && (widget.isActive || _hovered);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: _tabHeight,
          margin: const EdgeInsets.only(right: 2),
          padding: EdgeInsets.only(
            left: 12,
            right: showCloseControl ? 4 : 12,
          ),
          decoration: BoxDecoration(
            color: widget.isActive
                ? _activeTabBackground
                : _inactiveTabBackground,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
              top: BorderSide(
                color: widget.isActive ? _tabBorderColor : Colors.transparent,
              ),
              left: BorderSide(
                color: widget.isActive ? _tabBorderColor : Colors.transparent,
              ),
              right: BorderSide(
                color: widget.isActive ? _tabBorderColor : Colors.transparent,
              ),
            ),
            boxShadow: widget.isActive
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 2,
                      offset: Offset(0, -1),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: widget.isActive
                        ? FontWeight.w600
                        : FontWeight.w500,
                    color: widget.isActive
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCloseControl)
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: widget.isActive
                          ? AppColors.textSecondary
                          : AppColors.textSecondary.withValues(alpha: 0.7),
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

/// Fixed “tab head” to toggle sales history, left of the new-tab (+) control.
class _HistoryHeadButton extends StatelessWidget {
  const _HistoryHeadButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Show sales history',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          child: Container(
            width: _historyHeadWidth,
            height: _tabHeight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: _inactiveTabBackground,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'History',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddTabButton extends StatelessWidget {
  const _AddTabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: _trailingControlSize,
          height: _trailingControlSize,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.add, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _MinimizeFormButton extends StatelessWidget {
  const _MinimizeFormButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Minimize',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: _trailingControlSize,
            height: _trailingControlSize,
            decoration: BoxDecoration(
              color: _activeTabBackground,
              shape: BoxShape.circle,
              border: Border.all(color: _tabBorderColor),
            ),
            child: const Icon(
              Icons.minimize,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

class _CloseFormButton extends StatelessWidget {
  const _CloseFormButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Close',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: _trailingControlSize,
            height: _trailingControlSize,
            decoration: BoxDecoration(
              color: _activeTabBackground,
              shape: BoxShape.circle,
              border: Border.all(color: _tabBorderColor),
            ),
            child: const Icon(
              Icons.close,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
