import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/collaboration/application/permission_service_provider.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_action.dart';
import 'package:billing_baba/features/collaboration/domain/models/permission_module.dart';
import 'package:billing_baba/features/collaboration/permissions/permission_gate.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/models/brand_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/brands/mobile_add_brand_sheet.dart';
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

/// Mobile brands list with search and add/edit/delete.
class MobileBrandsScreen extends ConsumerStatefulWidget {
  const MobileBrandsScreen({super.key});

  @override
  ConsumerState<MobileBrandsScreen> createState() => _MobileBrandsScreenState();
}

class _MobileBrandsScreenState extends ConsumerState<MobileBrandsScreen> {
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
        ref
            .read(inventoryBrandsProvider.notifier)
            .refresh(
              searchQuery: query.trim().isEmpty ? null : query.trim(),
            ),
      );
    });
  }

  Future<void> _onRefresh() {
    return ref
        .read(inventoryBrandsProvider.notifier)
        .refresh(
          searchQuery: _searchQuery.isEmpty ? null : _searchQuery,
        );
  }

  List<BrandModel> _filteredBrands(List<BrandModel> brands) {
    if (_searchQuery.isEmpty) return brands;
    return brands
        .where((brand) => brand.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _addBrand() => showMobileAddBrandSheet(context);

  Future<void> _editBrand(BrandModel brand) {
    return showMobileAddBrandSheet(context, editBrand: brand);
  }

  Future<void> _confirmDeleteBrand(BrandModel brand) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete brand?'),
        content: Text('Delete "${brand.name}"?'),
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
        .read(inventoryBrandsProvider.notifier)
        .deleteBrand(brand.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  void _showBrandActions(BrandModel brand) {
    final permissions = ref.read(permissionServiceProvider);
    final actions = <MobileSheetAction>[
      if (permissions.canEdit(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.edit_outlined,
          label: 'Edit Brand',
          onTap: () => unawaited(_editBrand(brand)),
        ),
      if (permissions.canDelete(PermissionModule.item))
        MobileSheetAction(
          icon: Icons.delete_outline_rounded,
          label: 'Delete Brand',
          onTap: () => unawaited(_confirmDeleteBrand(brand)),
        ),
    ];
    if (actions.isEmpty) return;
    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: brand.name,
        actions: actions,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brandsAsync = ref.watch(inventoryBrandsProvider);
    final brands = _filteredBrands(brandsAsync.value ?? const []);
    final isInitialLoading = brandsAsync.isLoading && brands.isEmpty;
    final showError = brandsAsync.hasError && brands.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Brands',
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
                  hint: 'Search Brand',
                  onChanged: _onSearchChanged,
                ),
              ),
              const _BrandListHeader(),
              Expanded(
                child: switch ((isInitialLoading, showError, brands.isEmpty)) {
                  (true, _, _) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  (_, true, _) => Center(
                    child: AppError(
                      message: 'Could not load brands',
                      onRetry: _onRefresh,
                    ),
                  ),
                  (_, _, true) => MobileEmptyState(
                    title: 'No brands found',
                    message: 'Add a brand to organize your items.',
                    icon: Icons.branding_watermark_outlined,
                    actionLabel:
                        ref
                            .read(permissionServiceProvider)
                            .canCreate(PermissionModule.item)
                        ? 'Add Brand'
                        : null,
                    onAction:
                        ref
                            .read(permissionServiceProvider)
                            .canCreate(PermissionModule.item)
                        ? () => unawaited(_addBrand())
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
                          itemCount: brands.length,
                          separatorBuilder: (_, _) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            final brand = brands[index];
                            return _BrandListRow(
                              brand: brand,
                              onTap: () => _showBrandActions(brand),
                            );
                          },
                        ),
                      ),
                      if (brandsAsync.isLoading)
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
            child: PermissionGate(
              module: PermissionModule.item,
              action: PermissionAction.create,
              child: Center(
                child: _AddBrandFab(onPressed: () => unawaited(_addBrand())),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BrandListHeader extends StatelessWidget {
  const _BrandListHeader();

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
              'BRAND NAME',
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

class _BrandListRow extends StatelessWidget {
  const _BrandListRow({
    required this.brand,
    required this.onTap,
  });

  final BrandModel brand;
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
          children: [
            Expanded(
              child: Text(
                brand.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              '${brand.itemCount}',
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

class _AddBrandFab extends StatelessWidget {
  const _AddBrandFab({required this.onPressed});

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
                'Add Brand',
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
