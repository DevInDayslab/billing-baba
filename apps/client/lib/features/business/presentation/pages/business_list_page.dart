import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_card.dart';
import 'package:billing_baba/features/business/presentation/widgets/create_business_dialog.dart';
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

  Future<void> _openCreateBusiness() async {
    final created = await showCreateBusinessModal(context);
    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Business created successfully')),
      );
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessListProvider);
    final phoneNumber = ref.watch(loggedInPhoneProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: businessesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          onRetry: () => ref.read(businessListProvider.notifier).refresh(),
        ),
        data: (allBusinesses) {
          if (allBusinesses.isEmpty) {
            return Column(
              children: [
                const _SupportBar(),
                Expanded(
                  child: _EmptyBusinessState(onCreate: _openCreateBusiness),
                ),
                _BottomBar(
                  phoneNumber: phoneNumber,
                  onCreate: _openCreateBusiness,
                  showNewCompany: false,
                ),
              ],
            );
          }

          final sharedBusinesses = _filterBusinesses(
            allBusinesses.where((b) => b.isShared).toList(),
          );
          final myBusinesses = _filterBusinesses(
            allBusinesses.where((b) => !b.isShared).toList(),
          );

          return Column(
            children: [
              const _SupportBar(),
              _Header(
                searchController: _searchController,
                tabController: _tabController,
                onSearchChanged: () => setState(() {}),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () =>
                      ref.read(businessListProvider.notifier).refresh(),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxContentWidth,
                      ),
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
              ),
              _BottomBar(
                phoneNumber: phoneNumber,
                onCreate: _openCreateBusiness,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EmptyBusinessState extends StatelessWidget {
  const _EmptyBusinessState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: AppRadius.xlBorder,
                ),
                child: Icon(
                  Icons.storefront_outlined,
                  size: 56,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'No Business Found',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Create your first business to start billing.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: onCreate,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size(220, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.mdBorder,
                  ),
                ),
                child: const Text('Create Business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 48,
            color: AppColors.error,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text('Could not load businesses'),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: const Text('Try again')),
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
      return ListView(
        children: const [
          SizedBox(height: 120),
          Center(child: Text('No shared companies to show')),
        ],
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
          onOpen: () => _openBusiness(context, ref, business.id),
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
              onOpen: () => _openBusiness(context, ref, business.id),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _openBusiness(
  BuildContext context,
  WidgetRef ref,
  String businessId,
) async {
  await ref.read(businessListProvider.notifier).selectBusiness(businessId);
  if (context.mounted) {
    context.go(AppRoutes.home);
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.phoneNumber,
    required this.onCreate,
    this.showNewCompany = true,
  });

  final String phoneNumber;
  final VoidCallback onCreate;
  final bool showNewCompany;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade300)),
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
                    const Icon(
                      Icons.phone,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                if (showNewCompany)
                  FilledButton(
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('New Company'),
                  ),
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  child: const Text('Logout'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
