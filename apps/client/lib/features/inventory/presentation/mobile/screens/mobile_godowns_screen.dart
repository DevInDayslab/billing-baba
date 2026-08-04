import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/godowns/mobile_add_godown_sheet.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile godowns list with search and add/edit/delete.
class MobileGodownsScreen extends ConsumerStatefulWidget {
  const MobileGodownsScreen({super.key});

  @override
  ConsumerState<MobileGodownsScreen> createState() =>
      _MobileGodownsScreenState();
}

class _MobileGodownsScreenState extends ConsumerState<MobileGodownsScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query.trim().toLowerCase());
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      unawaited(
        ref.read(inventoryGodownsProvider.notifier).refresh(
              searchQuery: query.trim().isEmpty ? null : query.trim(),
            ),
      );
    });
  }

  Future<void> _onRefresh() {
    return ref.read(inventoryGodownsProvider.notifier).refresh(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }

  List<GodownModel> _filteredGodowns(List<GodownModel> godowns) {
    if (_searchQuery.isEmpty) return godowns;
    return godowns
        .where((godown) => godown.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _addGodown() => showMobileAddGodownSheet(context);

  Future<void> _editGodown(GodownModel godown) {
    return showMobileAddGodownSheet(context, editGodown: godown);
  }

  Future<void> _confirmDeleteGodown(GodownModel godown) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete godown?'),
        content: Text('Delete "${godown.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final error = await ref
        .read(inventoryGodownsProvider.notifier)
        .deleteGodown(godown.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _showGodownActions(GodownModel godown) {
    final permissions = ref.read(permissionServiceProvider);
    final actions = <MobileSheetAction>[
      if (permissions.canEdit(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.edit_outlined,
          label: 'Edit Godown',
          onTap: () => unawaited(_editGodown(godown)),
        ),
      if (permissions.canDelete(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Godown',
          onTap: () => unawaited(_confirmDeleteGodown(godown)),
        ),
    ];
    if (actions.isEmpty) return;
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: godown.name,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);
    final godowns = _filteredGodowns(godownsAsync.value ?? const []);
    final isInitialLoading = godownsAsync.isLoading && godowns.isEmpty;
    final showError = godownsAsync.hasError && godowns.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Godowns',
        showBusinessHeader: false,
        showNotification: false,
        onSettingsTap: () => context.push(AppRoutes.itemsSettings),
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.sm,
                ),
                child: MobileSearchField(
                  controller: _searchController,
                  hint: 'Search Godown',
                  onChanged: _onSearchChanged,
                ),
              ),
              const _GodownListHeader(),
              Expanded(
                child: switch ((isInitialLoading, showError, godowns.isEmpty)) {
                  (true, _, _) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  (_, true, _) => Center(
                    child: AppError(
                      message: 'Could not load godowns',
                      onRetry: _onRefresh,
                    ),
                  ),
                  (_, _, true) => MobileEmptyState(
                    title: 'No godowns found',
                    message: 'Add a godown to track stock by warehouse.',
                    icon: Icons.warehouse_outlined,
                    actionLabel: ref
                            .read(permissionServiceProvider)
                            .canCreate(PermissionModule.item)
                        ? 'Add Godown'
                        : null,
                    onAction: ref
                            .read(permissionServiceProvider)
                            .canCreate(PermissionModule.item)
                        ? () => unawaited(_addGodown())
                        : null,
                  ),
                  _ => Stack(
                    children: [
                      RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: MobileBottomNavigation.scrollBottomPadding(
                              context,
                              floatingActionHeight: 44,
                            ),
                          ),
                          itemCount: godowns.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            final godown = godowns[index];
                            return _GodownListRow(
                              godown: godown,
                              onTap: () => _showGodownActions(godown),
                            );
                          },
                        ),
                      ),
                      if (godownsAsync.isLoading)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  ),
                },
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MobileBottomNavigation.floatingActionBottomOffset(context),
            child: Center(
            child: PermissionGate(
              module: PermissionModule.item,
              action: PermissionAction.create,
              child: _AddGodownFab(onPressed: () => unawaited(_addGodown())),
            ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GodownListHeader extends StatelessWidget {
  const _GodownListHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.sm + 2,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'GODOWN',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            'ITEMS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _GodownListRow extends StatelessWidget {
  const _GodownListRow({
    required this.godown,
    required this.onTap,
  });

  final GodownModel godown;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          godown.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (godown.isDefault) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'DEFAULT',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (godown.address != null &&
                      godown.address!.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      godown.address!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            Text(
              '${godown.stockItemCount}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddGodownFab extends StatelessWidget {
  const _AddGodownFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileHomeAddSaleFab.accentRed,
      elevation: 2,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add Godown',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
