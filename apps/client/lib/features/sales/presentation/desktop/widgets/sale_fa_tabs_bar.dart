import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/application/add_sale_fa_form_provider.dart';
import 'package:billing_baba/features/sales/application/sale_fa_tabs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _barBackground = Color(0xFFDEE1E6);
const _activeTabBackground = Color(0xFFFFFFFF);
const _inactiveTabBackground = Color(0xFFE3E5E8);
const _tabBorderColor = Color(0xFFC5C9CE);
const _tabMinWidth = 80.0;
const _tabMaxWidth = 200.0;
const _tabHeight = 34.0;

/// Chrome-style tab strip for running multiple add-sale-fa sessions.
class SaleFaTabsBar extends ConsumerWidget {
  const SaleFaTabsBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(saleFaTabsProvider());
    final tabsNotifier = ref.read(saleFaTabsProvider().notifier);
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
                    final addButtonSpace = tabsNotifier.canAddTab ? 36.0 : 0.0;
                    final available = constraints.maxWidth - addButtonSpace;
                    final idealWidth = tabCount == 0
                        ? _tabMaxWidth
                        : (available / tabCount).clamp(
                            _tabMinWidth,
                            _tabMaxWidth,
                          );
                    final totalIdealWidth = idealWidth * tabCount;
                    final tabWidth = totalIdealWidth > available
                        ? (available / tabCount).clamp(
                            _tabMinWidth,
                            _tabMaxWidth,
                          )
                        : idealWidth;

                    final tabsRow = Row(
                      children: [
                        for (var i = 0; i < tabCount; i++)
                          SizedBox(
                            width: tabWidth,
                            child: _SaleFaTabChip(
                              label: tabsState.tabs[i].label,
                              isActive: i == tabsState.activeIndex,
                              showClose: tabCount > 1,
                              onTap: () => tabsNotifier.selectTab(i),
                              onClose: () => _closeTab(ref, tabsNotifier, i),
                            ),
                          ),
                      ],
                    );

                    if (tabWidth * tabCount > available + 0.5) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: tabsRow,
                      );
                    }
                    return tabsRow;
                  },
                ),
              ),
              if (tabsNotifier.canAddTab) ...[
                const SizedBox(width: 4),
                _AddTabButton(onTap: tabsNotifier.addTab),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _closeTab(WidgetRef ref, SaleFaTabs tabsNotifier, int index) {
    final tabsState = ref.read(saleFaTabsProvider());
    if (index < 0 || index >= tabsState.tabs.length) return;
    final sessionKey = tabsState.tabs[index].sessionKey;
    ref.invalidate(addSaleFaFormProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleFaGrandTotalProvider(sessionKey: sessionKey));
    ref.invalidate(addSaleFaTotalTaxProvider(sessionKey: sessionKey));
    tabsNotifier.closeTab(index);
  }
}

class _SaleFaTabChip extends StatefulWidget {
  const _SaleFaTabChip({
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
  State<_SaleFaTabChip> createState() => _SaleFaTabChipState();
}

class _SaleFaTabChipState extends State<_SaleFaTabChip> {
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
          width: 28,
          height: 28,
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
