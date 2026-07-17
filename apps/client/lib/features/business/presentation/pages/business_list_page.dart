import 'dart:async';

import 'package:billing_baba/core/network/api_error_parser.dart';
import 'package:billing_baba/core/providers/business_scope_invalidation.dart';
import 'package:billing_baba/core/router/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/auth/providers/auth_provider.dart';
import 'package:billing_baba/features/business/application/business_service.dart';
import 'package:billing_baba/features/business/models/business_model.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_card.dart';
import 'package:billing_baba/features/business/presentation/widgets/business_opening_overlay.dart';
import 'package:billing_baba/features/business/presentation/widgets/create_business_dialog.dart';
import 'package:billing_baba/features/business/presentation/widgets/delete_business_dialog.dart';
import 'package:billing_baba/features/business/presentation/widgets/edit_business_dialog.dart';
import 'package:billing_baba/features/business/utils/business_open_debug_log.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class BusinessListPage extends ConsumerStatefulWidget {
  const BusinessListPage({super.key});

  @override
  ConsumerState<BusinessListPage> createState() => _BusinessListPageState();
}

/// Preview card for the "Companies Shared with Me" tab.
const kDemoSharedBusinessId = 'demo-shared-sharma-traders';

const _demoSharedBusiness = BusinessModel(
  id: kDemoSharedBusinessId,
  name: 'Sharma Traders',
  syncStatus: SyncStatus.on,
  isShared: true,
  ownerName: 'Ramesh Sharma',
  role: 'Biller',
);

class _BusinessListPageState extends ConsumerState<BusinessListPage>
    with SingleTickerProviderStateMixin {
  static const _headerColor = Color(0xFF1A1A2E);
  static const _maxContentWidth = 1040.0;
  static const _supportPhone = '9333911911 / 080-68195500';
  static const _supportEmail = 'support@billingbaba.com';

  late final TabController _tabController;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<BusinessModel> _filterBusinesses(List<BusinessModel> businesses) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return businesses;
    return businesses.where((business) {
      final name = business.name.toLowerCase();
      final gstin = business.gstin?.toLowerCase() ?? '';
      final owner = business.ownerName?.toLowerCase() ?? '';
      return name.contains(query) ||
          gstin.contains(query) ||
          owner.contains(query);
    }).toList();
  }

  Future<void> _openCreateBusiness() async {
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
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Business created successfully')),
    );
    context.go(AppRoutes.home);
  }

  Future<void> _handleCardAction(
    BusinessModel business,
    BusinessCardAction action,
  ) async {
    switch (action) {
      case BusinessCardAction.edit:
        final updated = await showEditBusinessModal(
          context,
          businessId: business.id,
        );
        if (!mounted || updated != true) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${business.name} updated successfully')),
        );
      case BusinessCardAction.delete:
        final confirmed = await showDeleteBusinessDialog(
          context,
          companyName: business.name,
        );
        if (!mounted || confirmed != true) return;

        final container = ProviderScope.containerOf(context, listen: false);
        try {
          await container
              .read(businessListProvider.notifier)
              .deleteBusiness(business.id);
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${business.name} deleted')),
          );
        } on Object catch (error) {
          if (!context.mounted) return;
          final message = error is DioException
              ? ApiErrorParser.userFacingMessage(error)
              : 'Could not delete company. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessesAsync = ref.watch(businessListProvider);
    final phoneNumber = ref.watch(loggedInPhoneProvider);
    final openingBusinessId = ref.watch(businessSessionLoadingProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          businessesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorState(
              onRetry: () => ref.read(businessListProvider.notifier).refresh(),
            ),
            data: (allBusinesses) {
              if (allBusinesses.isEmpty) {
                return Column(
                  children: [
                    const _SupportBar(phone: _supportPhone),
                    Expanded(
                      child: _EmptyBusinessState(onCreate: _openCreateBusiness),
                    ),
                    _BottomBar(
                      phoneNumber: phoneNumber,
                      supportEmail: _supportEmail,
                      onCreate: _openCreateBusiness,
                      showNewCompany: false,
                    ),
                  ],
                );
              }

              final sharedBusinesses = _filterBusinesses([
                _demoSharedBusiness,
                ...allBusinesses.where((b) => b.isShared),
              ]);
              final myBusinesses = _filterBusinesses(
                allBusinesses.where((b) => !b.isShared).toList(),
              );

              return Column(
                children: [
                  const _SupportBar(phone: _supportPhone),
                  _Header(
                    searchController: _searchController,
                    searchFocusNode: _searchFocusNode,
                    tabController: _tabController,
                    onSearchChanged: () => setState(() {}),
                    onCreate: _openCreateBusiness,
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
                              _SharedCompaniesTab(
                                businesses: sharedBusinesses,
                                onAction: _handleCardAction,
                              ),
                              _MyCompaniesTab(
                                businesses: myBusinesses,
                                onCreate: _openCreateBusiness,
                                onAction: _handleCardAction,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  _BottomBar(
                    phoneNumber: phoneNumber,
                    supportEmail: _supportEmail,
                    onCreate: _openCreateBusiness,
                  ),
                ],
              );
            },
          ),
          if (openingBusinessId != null) const BusinessOpeningOverlay(),
        ],
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
                  borderRadius: AppRadius.lgBorder,
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
  const _SupportBar({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm + 2,
      ),
      child: Center(
        child: Text(
          'Need help? Call $phone — Get Instant Online Support',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
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
    required this.searchFocusNode,
    required this.tabController,
    required this.onSearchChanged,
    required this.onCreate,
  });

  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final TabController tabController;
  final VoidCallback onSearchChanged;
  final VoidCallback onCreate;

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
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Company List',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Manage all your businesses from one place.',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    FilledButton.icon(
                      onPressed: onCreate,
                      icon: const Icon(
                        Icons.add,
                        size: 18,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'New Company',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.mdBorder,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: searchController,
                  builder: (context, value, _) {
                    return TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      onChanged: (_) => onSearchChanged(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search companies by name, GSTIN or owner...',
                        hintStyle: TextStyle(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.75),
                          size: 22,
                        ),
                        suffixIcon: value.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.white.withValues(alpha: 0.7),
                                  size: 20,
                                ),
                                onPressed: () {
                                  searchController.clear();
                                  onSearchChanged();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.1),
                        hoverColor: Colors.white.withValues(alpha: 0.02),
                        border: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppRadius.mdBorder,
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.45),
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                TabBar(
                  controller: tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 2.5,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.55),
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  dividerColor: Colors.white.withValues(alpha: 0.12),
                  dividerHeight: 1,
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
  const _SharedCompaniesTab({
    required this.businesses,
    required this.onAction,
  });

  final List<BusinessModel> businesses;
  final void Function(BusinessModel, BusinessCardAction) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (businesses.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text(
              'No shared companies to show',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      itemCount: businesses.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final business = businesses[index];
        return BusinessCard(
          business: business,
          onOpen: () async {
            if (business.id == kDemoSharedBusinessId) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Preview only — shared access will open once backend sync is connected.',
                  ),
                ),
              );
              return;
            }
            await _openBusiness(context, ref, business.id);
          },
          onAction: (action) => onAction(business, action),
        );
      },
    );
  }
}

class _MyCompaniesTab extends ConsumerWidget {
  const _MyCompaniesTab({
    required this.businesses,
    required this.onCreate,
    required this.onAction,
  });

  final List<BusinessModel> businesses;
  final VoidCallback onCreate;
  final void Function(BusinessModel, BusinessCardAction) onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      children: [
        Text(
          'Select a company to continue billing and inventory management.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        ...businesses.map(
          (business) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: BusinessCard(
              business: business,
              onOpen: () => _openBusiness(context, ref, business.id),
              onAction: (action) => onAction(business, action),
            ),
          ),
        ),
        if (businesses.isNotEmpty) const SizedBox(height: AppSpacing.sm),
        _CreateBusinessCard(onCreate: onCreate),
      ],
    );
  }
}

class _CreateBusinessCard extends StatefulWidget {
  const _CreateBusinessCard({required this.onCreate});

  final VoidCallback onCreate;

  @override
  State<_CreateBusinessCard> createState() => _CreateBusinessCardState();
}

class _CreateBusinessCardState extends State<_CreateBusinessCard> {
  var _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: _isHovered
                ? AppColors.primary.withValues(alpha: 0.35)
                : const Color(0xFFE8EAED),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovered ? 0.06 : 0.03),
              blurRadius: _isHovered ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppColors.primary),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create a new business',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Add another company to manage from this account.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            FilledButton.icon(
              onPressed: widget.onCreate,
              icon: const Icon(Icons.add, size: 18, color: Colors.white),
              label: const Text(
                'New Company',
                style: TextStyle(color: Colors.white),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppRadius.mdBorder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openBusiness(
  BuildContext context,
  WidgetRef ref,
  String businessId,
) async {
  final container = ProviderScope.containerOf(context, listen: false);
  final loading = container.read(businessSessionLoadingProvider.notifier);
  loading.start(businessId);

  try {
    BusinessOpenDebugLog.step('ui', 'calling openBusiness');
    await container
        .read(businessListProvider.notifier)
        .openBusiness(businessId);
    BusinessOpenDebugLog.step('ui', 'openBusiness returned — navigating home');
    if (!context.mounted) return;
    context.go(AppRoutes.home);
    BusinessOpenDebugLog.step('ui', 'navigation dispatched');
  } on BusinessSelectionFailed catch (error) {
    BusinessOpenDebugLog.step('ui', 'failed: ${error.message}');
    if (!context.mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(error.message)),
    );
  } on Object catch (error) {
    BusinessOpenDebugLog.step('ui', 'failed: $error');
    if (!context.mounted) return;
    final message = error is DioException
        ? ApiErrorParser.userFacingMessage(error)
        : 'Could not open company. Please try again.';
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      SnackBar(content: Text(message)),
    );
  } finally {
    loading.clear();
    BusinessOpenDebugLog.step('ui', 'loading overlay cleared');
  }
}

class _BottomBar extends ConsumerWidget {
  const _BottomBar({
    required this.phoneNumber,
    required this.supportEmail,
    required this.onCreate,
    this.showNewCompany = true,
  });

  final String phoneNumber;
  final String supportEmail;
  final VoidCallback onCreate;
  final bool showNewCompany;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final captionStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: AppColors.textSecondary,
      fontSize: 12,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: _BusinessListPageState._maxContentWidth,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 4,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: AppSpacing.lg,
                    runSpacing: AppSpacing.xs,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _FooterContactItem(
                        icon: Icons.phone_outlined,
                        label: phoneNumber,
                        style: captionStyle,
                      ),
                      _FooterContactItem(
                        icon: Icons.email_outlined,
                        label: supportEmail,
                        style: captionStyle,
                      ),
                    ],
                  ),
                ),
                if (showNewCompany) ...[
                  FilledButton(
                    onPressed: onCreate,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.mdBorder,
                      ),
                    ),
                    child: const Text(
                      'New Company',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                ],
                TextButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) context.go(AppRoutes.login);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                  ),
                  child: Text(
                    'Logout',
                    style: captionStyle?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterContactItem extends StatelessWidget {
  const _FooterContactItem({
    required this.icon,
    required this.label,
    required this.style,
  });

  final IconData icon;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Text(label, style: style),
      ],
    );
  }
}
