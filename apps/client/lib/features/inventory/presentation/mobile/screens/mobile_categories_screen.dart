import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/core/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_bottom_navigation.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_empty_state.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheet_models.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_sheets.dart';
import 'package:billing_baba/features/dashboard/presentation/mobile/widgets/mobile_home_fab.dart';
import 'package:billing_baba/features/inventory/application/inventory_categories_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/features/inventory/inventory_constants.dart';
import 'package:billing_baba/features/inventory/models/category_model.dart';
import 'package:billing_baba/features/inventory/presentation/mobile/widgets/categories/mobile_add_category_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Mobile categories list with search, item counts, and add/edit/delete.
class MobileCategoriesScreen extends ConsumerStatefulWidget {
  const MobileCategoriesScreen({super.key});

  @override
  ConsumerState<MobileCategoriesScreen> createState() =>
      _MobileCategoriesScreenState();
}

class _MobileCategoriesScreenState extends ConsumerState<MobileCategoriesScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

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
    ref.read(categorySearchQueryProvider.notifier).query = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final trimmed = query.trim();
      ref.read(categoryBackendSearchProvider.notifier).query = trimmed;
      unawaited(
        ref.read(inventoryCategoriesProvider.notifier).refresh(
              searchQuery: trimmed.isEmpty ? null : trimmed,
            ),
      );
    });
  }

  Future<void> _onRefresh() {
    return ref.read(inventoryCategoriesProvider.notifier).refresh(
          searchQuery: ref.read(categoryBackendSearchProvider),
        );
  }

  Future<void> _addCategory() {
    return showMobileAddCategorySheet(context);
  }

  Future<void> _editCategory(InventoryCategory category) {
    return showMobileAddCategorySheet(context, editCategory: category);
  }

  Future<void> _confirmDeleteCategory(InventoryCategory category) async {
    if (category.isUncategorized) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete category?'),
        content: Text('Delete "${category.name}"?'),
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
        .read(inventoryCategoriesProvider.notifier)
        .deleteCategory(category.id);
    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    ref.read(selectedCategoryIdProvider.notifier).selected =
        uncategorizedCategoryId;
  }

  void _showCategoryActions(InventoryCategory category) {
    if (category.isUncategorized) return;

    unawaited(
      showMobileMoreActionsSheet(
        context: context,
        title: category.name,
        actions: [
          MobileSheetAction(
            icon: Icons.edit_outlined,
            label: 'Edit Category',
            onTap: () => unawaited(_editCategory(category)),
          ),
          MobileSheetAction(
            icon: Icons.delete_outline_rounded,
            label: 'Delete Category',
            onTap: () => unawaited(_confirmDeleteCategory(category)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
    final categoriesAsync = ref.watch(inventoryCategoriesProvider);
    final isInitialLoading = categoriesAsync.isLoading && categories.isEmpty;
    final showError = categoriesAsync.hasError && categories.isEmpty;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: MobileAppBar(
        showBackButton: true,
        title: 'Categories',
        showBusinessHeader: false,
        showNotification: false,
        showSettings: true,
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
                  hint: 'Search Category',
                  onChanged: _onSearchChanged,
                ),
              ),
              const _CategoryListHeader(),
              Expanded(
                child: switch ((isInitialLoading, showError, categories.isEmpty)) {
                  (true, _, _) => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  (_, true, _) => Center(
                    child: AppError(
                      message: 'Could not load categories',
                      onRetry: _onRefresh,
                    ),
                  ),
                  (_, _, true) => MobileEmptyState(
                    title: 'No categories found',
                    message: 'Add a category to organize your items.',
                    icon: Icons.category_outlined,
                    actionLabel: 'Add Category',
                    onAction: () => unawaited(_addCategory()),
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
                          itemCount: categories.length,
                          separatorBuilder: (_, __) => const Divider(
                            height: 1,
                            thickness: 1,
                            color: Color(0xFFEEEEEE),
                          ),
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            return _CategoryListRow(
                              category: category,
                              onTap: category.isUncategorized
                                  ? null
                                  : () => _showCategoryActions(category),
                            );
                          },
                        ),
                      ),
                      if (categoriesAsync.isLoading)
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
              child: _AddCategoryFab(onPressed: () => unawaited(_addCategory())),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListHeader extends StatelessWidget {
  const _CategoryListHeader();

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
              'Category Name',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            'Item Count',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryListRow extends StatelessWidget {
  const _CategoryListRow({
    required this.category,
    this.onTap,
  });

  final InventoryCategory category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      child: InkWell(
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
                  category.name,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${category.itemCount}',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddCategoryFab extends StatelessWidget {
  const _AddCategoryFab({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: MobileHomeAddSaleFab.accentRed,
      elevation: 2,
      shadowColor: MobileHomeAddSaleFab.accentRed.withValues(alpha: 0.25),
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
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Add Category',
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
