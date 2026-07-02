import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/master_detail_split_layout.dart';
import 'package:billing_baba/features/parties/presentation/widgets/add_party_dialog.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_detail_panel.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_list_panel.dart';
import 'package:billing_baba/features/parties/presentation/widgets/party_page_title_bar.dart';
import 'package:billing_baba/features/parties/providers/parties_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _successSnackBarColor = Color(0xFF2E7D32);

Future<void> _openAddPartyDialog(BuildContext context, WidgetRef ref) async {
  final result = await showAddPartyDialog(context);
  if (!context.mounted || result == null) return;

  final messenger = ScaffoldMessenger.maybeOf(context);
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
      duration: const Duration(seconds: 3),
    ),
  );
}

class PartyDetailsPage extends ConsumerWidget {
  const PartyDetailsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedParty = ref.watch(selectedPartyProvider);

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
                child: MasterDetailSplitLayout(
                  listPanel: const PartyListPanel(),
                  detailPanel: selectedParty == null
                      ? const MasterDetailPlaceholder(
                          message: 'Select a party to view details',
                        )
                      : PartyDetailPanel(party: selectedParty),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
