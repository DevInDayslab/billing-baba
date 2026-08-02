import 'dart:async';

import 'package:billing_baba/core/network/offline_ui_messages.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/application/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/presentation/desktop/widgets/create_business_dialog.dart';
import 'package:billing_baba/features/business/presentation/mobile/application/business_selection_controller.dart';
import 'package:billing_baba/features/business/presentation/mobile/widgets/business_selection_tile.dart';
import 'package:billing_baba/features/business/utils/switch_company_debug_log.dart';
import 'package:billing_baba/features/collaboration/application/company_directory_provider.dart';
import 'package:billing_baba/features/collaboration/application/company_session_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_list_entry.dart';
import 'package:billing_baba/features/collaboration/domain/models/company_relationship.dart';
import 'package:billing_baba/shared/widgets/app_button.dart';
import 'package:billing_baba/shared/widgets/app_empty.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile company picker — Vyapar-style list with tap-to-select + Continue.
class MobileBusinessListPage extends ConsumerStatefulWidget {
  const MobileBusinessListPage({super.key});

  @override
  ConsumerState<MobileBusinessListPage> createState() =>
      _MobileBusinessListPageState();
}

class _MobileBusinessListPageState
    extends ConsumerState<MobileBusinessListPage> {
  @override
  void initState() {
    super.initState();
    SwitchCompanyDebugLog.lifecycle('MobileBusinessListPage', 'initState');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(ref.read(companySessionServiceProvider.future));
    });
  }

  @override
  void dispose() {
    SwitchCompanyDebugLog.lifecycle('MobileBusinessListPage', 'dispose');
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(companyDirectoryProvider);
    await ref.read(companyDirectoryProvider.future);
  }

  Future<void> _onCreateBusiness() async {
    final created = await showCreateBusinessModal(context);
    if (!mounted || created != true) return;

    final auth = ref.read(authProvider);
    if (auth.status != AuthStatus.authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Business created. Select it from the list to continue.',
          ),
        ),
      );
      ref.invalidate(companyDirectoryProvider);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business created successfully')),
    );
    context.go(AppRoutes.home);
  }

  Future<void> _onContinue(List<CompanyListEntry> entries) async {
    final notifier = ref.read(mobileBusinessSelectionProvider.notifier);
    final errorMessage = await notifier.openSelectedCompany(entries);
    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
      return;
    }

    context.go(AppRoutes.home);
  }

  Future<void> _acceptInvite(CompanyListEntry entry) async {
    final invitationId = entry.invitationId;
    if (invitationId == null) return;
    try {
      final sessionService = await ref.read(
        companySessionServiceProvider.future,
      );
      final accepted = await sessionService.acceptInvite(invitationId);
      if (!mounted) return;
      ref.read(mobileBusinessSelectionProvider.notifier).select(accepted.id);
      ref.invalidate(companyDirectoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Joined ${accepted.name}')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OfflineUiMessages.messageFor(error))),
      );
    }
  }

  Future<void> _rejectInvite(CompanyListEntry entry) async {
    final invitationId = entry.invitationId;
    if (invitationId == null) return;
    try {
      final sessionService = await ref.read(
        companySessionServiceProvider.future,
      );
      await sessionService.rejectInvite(invitationId);
      if (!mounted) return;
      ref.invalidate(companyDirectoryProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invitation rejected')),
      );
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(OfflineUiMessages.messageFor(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final directoryAsync = ref.watch(companyDirectoryProvider);
    final directoryServiceAsync = ref.watch(companyDirectoryServiceProvider);
    final selection = ref.watch(mobileBusinessSelectionProvider);
    final phoneNumber = ref.watch(loggedInPhoneProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Select Business'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Create business',
            onPressed: _onCreateBusiness,
            icon: const Icon(Icons.add_business_outlined),
          ),
        ],
      ),
      body: directoryAsync.when(
        loading: () => const AppLoader(message: 'Loading businesses…'),
        error: (_, _) => AppError(
          message: 'Could not load businesses.',
          onRetry: () => ref.invalidate(companyDirectoryProvider),
        ),
        data: (allEntries) {
          if (allEntries.isEmpty) {
            return _EmptyState(onCreate: _onCreateBusiness);
          }

          final directoryService = directoryServiceAsync.value;
          final owned =
              directoryService?.ownedCompanies(allEntries) ??
              allEntries.where((e) => e.relationship.isOwner).toList();
          final shared =
              directoryService?.sharedCompanies(allEntries) ??
              allEntries.where((e) => e.isSharedTab).toList();

          return Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.md,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    children: [
                      Text(
                        'Choose a business to manage billing and inventory.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      if (owned.isNotEmpty) ...[
                        const _SectionHeader(title: 'My Businesses'),
                        const SizedBox(height: AppSpacing.sm),
                        ...owned.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: BusinessSelectionTile(
                              entry: entry,
                              isSelected: selection.selectedId == entry.id,
                              enabled: _isOpenable(entry),
                              onTap: () => ref
                                  .read(
                                    mobileBusinessSelectionProvider.notifier,
                                  )
                                  .select(entry.id),
                              onAccept: entry.relationship.isPending
                                  ? () => _acceptInvite(entry)
                                  : null,
                              onReject: entry.relationship.isPending
                                  ? () => _rejectInvite(entry)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      if (shared.isNotEmpty) ...[
                        if (owned.isNotEmpty)
                          const SizedBox(height: AppSpacing.sm),
                        const _SectionHeader(title: 'Shared with Me'),
                        const SizedBox(height: AppSpacing.sm),
                        ...shared.map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: BusinessSelectionTile(
                              entry: entry,
                              isSelected: selection.selectedId == entry.id,
                              enabled: _isOpenable(entry),
                              onTap: () => ref
                                  .read(
                                    mobileBusinessSelectionProvider.notifier,
                                  )
                                  .select(entry.id),
                              onAccept: entry.relationship.isPending
                                  ? () => _acceptInvite(entry)
                                  : null,
                              onReject: entry.relationship.isPending
                                  ? () => _rejectInvite(entry)
                                  : null,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.xxl),
                    ],
                  ),
                ),
              ),
              _BottomBar(
                phoneNumber: phoneNumber,
                canContinue: selection.canContinue,
                isLoading: selection.isOpening,
                onContinue: () => _onContinue(allEntries),
                onCreate: _onCreateBusiness,
                onLogout: () async {
                  await ref.read(authProvider.notifier).logout();
                  ref.read(mobileBusinessSelectionProvider.notifier).reset();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isOpenable(CompanyListEntry entry) {
    return !entry.relationship.isPending && !entry.relationship.isExpired;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AppEmpty(
      title: 'No Business Found',
      message: 'Create your first business to start billing.',
      action: AppButton(label: 'Create Business', onPressed: onCreate),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.phoneNumber,
    required this.canContinue,
    required this.isLoading,
    required this.onContinue,
    required this.onCreate,
    required this.onLogout,
  });

  final String phoneNumber;
  final bool canContinue;
  final bool isLoading;
  final VoidCallback onContinue;
  final VoidCallback onCreate;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phoneNumber.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Text(
                    'Signed in as $phoneNumber',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              AppButton(
                label: 'Continue',
                isLoading: isLoading,
                onPressed: canContinue ? onContinue : null,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: onCreate,
                    child: const Text('Create new business'),
                  ),
                  Text(
                    '·',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  TextButton(
                    onPressed: onLogout,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                    ),
                    child: const Text('Logout'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
