import 'dart:async';

import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/text_input_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/desktop/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_group_detail_panel.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_group_list_panel.dart';
import 'package:billing_baba/features/parties/presentation/desktop/widgets/party_page_title_bar.dart';
import 'package:billing_baba/features/parties/application/parties_providers.dart';
import 'package:billing_baba/features/parties/application/party_groups_provider.dart';
import 'package:billing_baba/features/sales/presentation/desktop/widgets/sale_field_decoration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _compactBreakpoint = 800.0;

Future<void> _openAddGroupDialog(BuildContext context, WidgetRef ref) async {
  final name = await showTextInputDialog(
    context,
    title: 'New Party Group',
    hint: 'Group name',
    confirmLabel: 'Add',
    textCapitalization: TextCapitalization.words,
    decoration: buildSaleFieldDecoration(hint: 'Group name'),
    textStyle: saleFieldTextStyle,
  );
  if (name == null || !context.mounted) return;

  final added = ref.read(partyGroupsProvider.notifier).addGroup(name);
  if (!added && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Group "$name" already exists')),
    );
    return;
  }

  ref.read(selectedPartyGroupProvider.notifier).selected = name.trim();
}

class DesktopPartyGroupsPage extends ConsumerStatefulWidget {
  const DesktopPartyGroupsPage({super.key});

  @override
  ConsumerState<DesktopPartyGroupsPage> createState() => _PartyGroupsPageState();
}

class _PartyGroupsPageState extends ConsumerState<DesktopPartyGroupsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializePage());
    });
  }

  Future<void> _initializePage() async {
    final partiesAsync = ref.read(partyListProvider);
    if (!partiesAsync.hasValue) {
      await ref.read(partyListProvider.notifier).refresh();
    }
    await ref.read(partyGroupsProvider.notifier).sync();
    await ref.read(allPartiesListProvider.future);
    if (!mounted) return;
    _ensureSelection();
  }

  void _ensureSelection() {
    final selected = ref.read(selectedPartyGroupProvider);
    final groups = ref.read(partyGroupsProvider);
    if (selected != null && groups.contains(selected)) return;
    if (groups.isNotEmpty) {
      ref.read(selectedPartyGroupProvider.notifier).selected = groups.first;
    }
  }

  void _clearSelection() {
    ref.read(selectedPartyGroupProvider.notifier).selected = null;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(partyGroupsProvider, (previous, next) {
      final selected = ref.read(selectedPartyGroupProvider);
      if (selected != null && next.contains(selected)) return;
      if (next.isNotEmpty) {
        ref.read(selectedPartyGroupProvider.notifier).selected = next.first;
      } else {
        ref.read(selectedPartyGroupProvider.notifier).selected = null;
      }
    });

    final selectedGroup = ref.watch(selectedPartyGroupProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PartyPageTitleBar(
                currentRoute: AppRoutes.partyGroups,
                onAddGroup: () => _openAddGroupDialog(context, ref),
                onSettingsTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < _compactBreakpoint;

                    if (isCompact) {
                      if (selectedGroup == null) {
                        return _buildInventoryShell(
                          child: const PartyGroupListPanel(),
                        );
                      }
                      return _buildInventoryShell(
                        child: PartyGroupDetailPanel(
                          groupName: selectedGroup,
                          onBack: _clearSelection,
                        ),
                      );
                    }

                    return InventorySplitLayout(
                      listWidth: 360,
                      listPanel: const PartyGroupListPanel(),
                      detailPanel: selectedGroup == null
                          ? const InventoryDetailPlaceholder(
                              message: 'Select a group to view parties',
                            )
                          : PartyGroupDetailPanel(groupName: selectedGroup),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryShell({required Widget child}) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: inventoryCardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: child,
      ),
    );
  }
}
