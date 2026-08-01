import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/application/inventory_providers.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum InventoryMasterType { categories, units, godowns }

class MobileInventoryMastersPage extends ConsumerWidget {
  const MobileInventoryMastersPage({
    required this.type,
    super.key,
  });

  final InventoryMasterType type;

  String get _title => switch (type) {
    InventoryMasterType.categories => 'Categories',
    InventoryMasterType.units => 'Units',
    InventoryMasterType.godowns => 'Godowns',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MobileAppBar(
        title: _title,
        showBusinessHeader: false,
        showNotification: false,
      ),
      body: switch (type) {
        InventoryMasterType.categories => _CategoriesList(),
        InventoryMasterType.units => _UnitsList(),
        InventoryMasterType.godowns => _GodownsList(),
      },
    );
  }
}

class _CategoriesList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    if (categories.isEmpty) {
      return const Center(
        child: Text('No categories', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: categories.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final category = categories[index];
        return _MasterTile(
          title: category.name,
          subtitle: '${category.itemCount} items',
        );
      },
    );
  }
}

class _UnitsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);

    if (units.isEmpty) {
      return const Center(
        child: Text('No units', style: TextStyle(color: AppColors.textSecondary)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: units.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final unit = units[index];
        return _MasterTile(
          title: unit.fullName,
          subtitle: unit.shortName,
        );
      },
    );
  }
}

class _GodownsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final godownsAsync = ref.watch(inventoryGodownsProvider);

    return godownsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text(error.toString())),
      data: (godowns) {
        if (godowns.isEmpty) {
          return const Center(
            child: Text(
              'No godowns',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: godowns.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final godown = godowns[index];
            return _MasterTile(
              title: godown.name,
              subtitle: godown.address ?? '${godown.stockItemCount} items',
            );
          },
        );
      },
    );
  }
}

class _MasterTile extends StatelessWidget {
  const _MasterTile({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      child: ListTile(
        title: Text(
          title,
          style: AppTypography.inter(fontSize: AppTypography.bodySize, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: AppTypography.inter(
            fontSize: AppTypography.captionSize,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
