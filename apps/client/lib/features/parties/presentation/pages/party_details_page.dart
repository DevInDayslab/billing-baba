import 'dart:async';

import 'package:billing_baba/core/network/api_validation_exception.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_split_layout.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/parties/application/party_service.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_detail_panel.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_list_panel.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_page_title_bar.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);
const _compactBreakpoint = 800.0;

Future<void> _openAddPartyDialog(BuildContext context, WidgetRef ref) async {
  final result = await showAddPartyDialog(context);
  if (!context.mounted || result == null) return;

  final messenger = ScaffoldMessenger.maybeOf(context);

  try {
    await ref.read(partyListProvider.notifier).createParty(result);
    if (!context.mounted) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(
          'Party "${result.partyName}" saved successfully',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: _successSnackBarColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } on PartyOfflineException {
    if (!context.mounted) return;
    messenger?.showSnackBar(
      const SnackBar(
        content: Text(
          'Party saved offline. It will sync when you are back online.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  } on ApiValidationException catch (e) {
    if (!context.mounted) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  } on PartyException catch (e) {
    if (!context.mounted) return;
    messenger?.showSnackBar(
      SnackBar(
        content: Text(e.message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class PartyDetailsPage extends ConsumerStatefulWidget {
  const PartyDetailsPage({super.key});

  @override
  ConsumerState<PartyDetailsPage> createState() => _PartyDetailsPageState();
}

class _PartyDetailsPageState extends ConsumerState<PartyDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_initializePage());
    });
  }

  Future<void> _initializePage() async {
    await ref.read(partyListProvider.notifier).refresh();
    if (!mounted) return;
    await _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    final service = await ref.read(partyServiceProvider.future);
    final remembered = service.readRememberedSelectedParty();
    if (remembered != null && mounted) {
      ref.read(selectedPartyIdProvider.notifier).selected = remembered;
    }
    final filter = service.readRememberedListFilter();
    if (filter != null && mounted) {
      ref.read(partyListFilterProvider.notifier).filter = filter;
    }
  }

  void _clearSelection() {
    ref.read(selectedPartyIdProvider.notifier).selected = null;
    unawaited(
      ref
          .read(partyServiceProvider.future)
          .then(
            (service) => service.rememberSelectedParty(null),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedId = ref.watch(selectedPartyIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PartyPageTitleBar(
                onAddParty: () => _openAddPartyDialog(context, ref),
                onSettingsTap: () {},
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isCompact = constraints.maxWidth < _compactBreakpoint;

                    if (isCompact) {
                      if (selectedId == null) {
                        return _buildInventoryShell(
                          child: const PartyListPanel(),
                        );
                      }
                      return _buildInventoryShell(
                        child: PartyDetailPanel(
                          partyId: selectedId,
                          onBack: _clearSelection,
                        ),
                      );
                    }

                    return InventorySplitLayout(
                      listWidth: 360,
                      listPanel: const PartyListPanel(),
                      detailPanel: selectedId == null
                          ? const InventoryDetailPlaceholder(
                              message: 'Select a party to view details',
                            )
                          : PartyDetailPanel(partyId: selectedId),
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
