import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/crm/application/deal_error_mapper.dart';
import 'package:billing_baba/features/crm/application/deals_provider.dart';
import 'package:billing_baba/features/crm/application/deals_selection_providers.dart';
import 'package:billing_baba/features/crm/domain/models/deal.dart';
import 'package:billing_baba/features/crm/domain/services/deal_service_types.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/add_deal_dialog.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/deals_filter_panel.dart';
import 'package:billing_baba/features/crm/presentation/desktop/widgets/deals_kanban_board.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_filter_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _createDealBlue = Color(0xFF1A62D6);
const _filterChipBg = Color(0xFFEAF2FB);
const _filterChipBorder = Color(0xFFD6E6F5);
const _toolbarBorder = Color(0xFFE0E0E0);
const _compactBreakpoint = 720.0;
const _filterOverlayBreakpoint = 1180.0;

class DesktopDealsScreen extends ConsumerStatefulWidget {
  const DesktopDealsScreen({super.key});

  @override
  ConsumerState<DesktopDealsScreen> createState() => _DealsScreenState();
}

class _DealsScreenState extends ConsumerState<DesktopDealsScreen> {
  Future<void> _saveDeal(AddDealInput input) async {
    try {
      await ref
          .read(dealsProvider.notifier)
          .addDeal(
            AddDealServiceInput.fromDialogInput(
              name: input.name,
              stage: input.stage,
              accountName: input.accountName,
              owner: input.owner,
              amount: input.amount,
              expectedCloseDate: input.expectedCloseDate,
              description: input.description,
            ),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Deal "${input.name}" saved successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DealErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _openAddDealDialog() async {
    final input = await showAddDealDialog(
      context,
      onSaveAndNew: _saveDeal,
    );
    if (!mounted || input == null) return;
    await _saveDeal(input);
  }

  Future<void> _moveDeal(Deal deal, DealStage newStage) async {
    try {
      await ref.read(dealsProvider.notifier).moveDealToStage(deal, newStage);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(DealErrorMapper.messageFor(error)),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dealsAsync = ref.watch(dealsProvider);
    final filterPanelOpen = ref.watch(dealFilterPanelOpenProvider);
    final filters = ref.watch(dealFiltersProvider);
    final filtersNotifier = ref.read(dealFiltersProvider.notifier);
    final viewMode = ref.watch(dealsViewModeStateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < _compactBreakpoint;
            final useFilterOverlay =
                constraints.maxWidth < _filterOverlayBreakpoint;
            final pagePadding = isCompact ? AppSpacing.sm : AppSpacing.md;

            return Padding(
              padding: EdgeInsets.all(pagePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _DealsTitleBar(
                    isCompact: isCompact,
                    onCreateDeal: _openAddDealDialog,
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  _DealsToolbar(
                    viewMode: viewMode,
                    filterPanelOpen: filterPanelOpen,
                    onToggleFilter: () =>
                        ref.read(dealFilterPanelOpenProvider.notifier).toggle(),
                    onViewModeChanged: (mode) => ref
                        .read(dealsViewModeStateProvider.notifier)
                        .setMode(mode),
                    onCreateDeal: _openAddDealDialog,
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  _DealsFilterChips(
                    ownerLabel: filters.ownerLabel,
                    accountLabel: filters.accountLabel,
                    onOwnerSelected: (value) {
                      filtersNotifier.setAssignedTo(
                        value == 'All Owners' ? null : value,
                      );
                    },
                    onAccountSelected: (value) {
                      filtersNotifier.setAccountName(
                        value == 'All Accounts' ? null : value,
                      );
                    },
                  ),
                  SizedBox(height: isCompact ? AppSpacing.sm : AppSpacing.md),
                  Expanded(
                    child: dealsAsync.when(
                      skipLoadingOnReload: true,
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, _) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(DealErrorMapper.messageFor(error)),
                            const SizedBox(height: AppSpacing.md),
                            FilledButton(
                              onPressed: () =>
                                  ref.read(dealsProvider.notifier).refresh(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                      data: (_) => Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (filterPanelOpen && !useFilterOverlay)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: AppSpacing.sm,
                              ),
                              child: DealsFilterPanel(
                                systemFilters: filters.systemFilters,
                                fieldFilters: filters.fieldFilters,
                                onSystemFilterToggle:
                                    filtersNotifier.toggleSystemFilter,
                                onFieldFilterToggle:
                                    filtersNotifier.toggleFieldFilter,
                              ),
                            ),
                          Expanded(
                            child: viewMode == DealsViewMode.kanban
                                ? DealsKanbanBoard(onMoveDeal: _moveDeal)
                                : const _DealsListPlaceholder(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DealsTitleBar extends StatelessWidget {
  const _DealsTitleBar({
    required this.isCompact,
    required this.onCreateDeal,
  });

  final bool isCompact;
  final VoidCallback onCreateDeal;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Deals',
          style: TextStyle(
            fontSize: isCompact ? 18 : 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
      ],
    );
  }
}

class _DealsToolbar extends StatelessWidget {
  const _DealsToolbar({
    required this.viewMode,
    required this.filterPanelOpen,
    required this.onToggleFilter,
    required this.onViewModeChanged,
    required this.onCreateDeal,
  });

  final DealsViewMode viewMode;
  final bool filterPanelOpen;
  final VoidCallback onToggleFilter;
  final ValueChanged<DealsViewMode> onViewModeChanged;
  final VoidCallback onCreateDeal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _toolbarBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const _ToolbarDropdown(label: 'All Deals'),
                _ToolbarButton(
                  icon: Icons.filter_list,
                  label: 'Filter',
                  selected: filterPanelOpen,
                  onPressed: onToggleFilter,
                ),
                _ToolbarButton(
                  icon: Icons.sort,
                  label: 'Sort',
                  onPressed: () {},
                ),
                _ViewModeToggle(
                  viewMode: viewMode,
                  onChanged: onViewModeChanged,
                ),
                const _ToolbarDropdown(label: 'STAGEVIEW'),
                IconButton(
                  tooltip: 'Edit stage view',
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 18),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            onPressed: onCreateDeal,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Create Deal'),
            style: FilledButton.styleFrom(
              backgroundColor: _createDealBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_drop_down),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
    );
  }
}

class _DealsFilterChips extends StatelessWidget {
  const _DealsFilterChips({
    required this.ownerLabel,
    required this.accountLabel,
    required this.onOwnerSelected,
    required this.onAccountSelected,
  });

  final String ownerLabel;
  final String accountLabel;
  final ValueChanged<String> onOwnerSelected;
  final ValueChanged<String> onAccountSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.xs,
      children: [
        SaleFilterDropdown(
          label: ownerLabel,
          chipBackgroundColor: _filterChipBg,
          chipBorderColor: _filterChipBorder,
          options: const [
            'All Owners',
            'Saksham Kochhar',
            'Priya Mehta',
            'Amit Verma',
          ],
          selected: ownerLabel,
          onSelected: onOwnerSelected,
        ),
        SaleFilterDropdown(
          label: accountLabel,
          chipBackgroundColor: _filterChipBg,
          chipBorderColor: _filterChipBorder,
          options: const [
            'All Accounts',
            'Acme Retail 1',
            'ABC Traders',
            'XYZ Enterprises',
          ],
          selected: accountLabel,
          onSelected: onAccountSelected,
        ),
      ],
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: selected ? AppColors.primary : AppColors.textPrimary,
        backgroundColor: selected ? _filterChipBg : null,
      ),
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}

class _ToolbarDropdown extends StatelessWidget {
  const _ToolbarDropdown({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: _toolbarBorder),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      ),
      icon: Text(label, style: const TextStyle(fontSize: 13)),
      label: const Icon(Icons.arrow_drop_down, size: 18),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.viewMode,
    required this.onChanged,
  });

  final DealsViewMode viewMode;
  final ValueChanged<DealsViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: _toolbarBorder),
        borderRadius: AppRadius.mdBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ViewModeIcon(
            icon: Icons.view_list,
            selected: viewMode == DealsViewMode.list,
            onTap: () => onChanged(DealsViewMode.list),
          ),
          _ViewModeIcon(
            icon: Icons.view_kanban_outlined,
            selected: viewMode == DealsViewMode.kanban,
            onTap: () => onChanged(DealsViewMode.kanban),
          ),
        ],
      ),
    );
  }
}

class _ViewModeIcon extends StatelessWidget {
  const _ViewModeIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        color: selected ? _filterChipBg : null,
        child: Icon(
          icon,
          size: 18,
          color: selected ? AppColors.primary : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _DealsListPlaceholder extends StatelessWidget {
  const _DealsListPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.mdBorder,
        border: Border.all(color: _toolbarBorder),
      ),
      child: const Text(
        'List view coming soon. Switch to Kanban view.',
        style: TextStyle(color: AppColors.textSecondary),
      ),
    );
  }
}
