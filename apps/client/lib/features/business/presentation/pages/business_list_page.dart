import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_card.dart';
import 'package:billing_baba/features/business/providers/business_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BusinessListPage extends ConsumerStatefulWidget {
  const BusinessListPage({super.key});

  @override
  ConsumerState<BusinessListPage> createState() => _BusinessListPageState();
}

class _BusinessListPageState extends ConsumerState<BusinessListPage>
    with SingleTickerProviderStateMixin {
  static const _headerColor = Color(0xFF1A1A2E);
  static const _maxContentWidth = 1040.0;
  static const _loggedInPhone = '7987016325';

  late final TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<BusinessModel> _filterBusinesses(List<BusinessModel> businesses) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return businesses;
    return businesses
        .where((business) => business.name.toLowerCase().contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final allBusinesses = ref.watch(businessListProvider);
    final sharedBusinesses =
        _filterBusinesses(allBusinesses.where((b) => b.isShared).toList());
    final myBusinesses =
        _filterBusinesses(allBusinesses.where((b) => !b.isShared).toList());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _SupportBar(),
          _Header(
            searchController: _searchController,
            tabController: _tabController,
            onSearchChanged: () => setState(() {}),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _maxContentWidth),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _SharedCompaniesTab(businesses: sharedBusinesses),
                    _MyCompaniesTab(businesses: myBusinesses),
                  ],
                ),
              ),
            ),
          ),
          _BottomBar(phoneNumber: _loggedInPhone),
        ],
      ),
    );
  }
}

class _SupportBar extends StatelessWidget {
  const _SupportBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Center(
        child: Text(
          'Need help? Call 9333911911 / 080-68195500 — Get Instant Online Support',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.tabController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final TabController tabController;
  final VoidCallback onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: _BusinessListPageState._headerColor,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _BusinessListPageState._maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.lg,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Company List',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search companies...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.mdBorder,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TabBar(
                  controller: tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
                  tabs: const [
                    Tab(text: 'Companies Shared with Me'),
                    Tab(text: 'My Companies'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SharedCompaniesTab extends ConsumerWidget {
  const _SharedCompaniesTab({required this.businesses});

  final List<BusinessModel> businesses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (businesses.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Shared Companies to Show',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: businesses.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final business = businesses[index];
        return BusinessCard(
          business: business,
          onOpen: () {
            ref.read(businessListProvider.notifier).selectBusiness(business.id);
            context.go(AppRoutes.home);
          },
        );
      },
    );
  }
}

class _MyCompaniesTab extends ConsumerWidget {
  const _MyCompaniesTab({required this.businesses});

  final List<BusinessModel> businesses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          'Select a company to continue billing and inventory management.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...businesses.map(
          (business) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: BusinessCard(
              business: business,
              onOpen: () {
                ref.read(businessListProvider.notifier).selectBusiness(business.id);
                context.go(AppRoutes.home);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.phoneNumber});

  final String phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _BusinessListPageState._maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.sm,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone, size: 18, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Restore backup'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    FilledButton(
                      onPressed: () {},
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      child: const Text('New Company'),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Logout'),
                    ),
                    Text(
                      'Logging out will stop syncing data',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
