import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/sales/presentation/widgets/preview_share_dialog.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_empty_state_card.dart';
import 'package:billing_baba/features/sales/presentation/widgets/sale_order_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _tabActiveColor = Color(0xFF1565C0);
const _cardBorder = Color(0xFFE0E0E0);

class SaleOrderPage extends ConsumerStatefulWidget {
  const SaleOrderPage({super.key});

  @override
  ConsumerState<SaleOrderPage> createState() => _SaleOrderPageState();
}

class _SaleOrderPageState extends ConsumerState<SaleOrderPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth < 600
              ? AppSpacing.md
              : AppSpacing.lg;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              AppSpacing.md,
              horizontalPadding,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  labelColor: _tabActiveColor,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: _tabActiveColor,
                  indicatorWeight: 3,
                  dividerColor: _cardBorder,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                  tabs: const [
                    Tab(text: 'SALE ORDERS'),
                    Tab(text: 'ONLINE ORDERS'),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AnimatedBuilder(
                  animation: _tabController,
                  builder: (context, _) {
                    if (_tabController.index == 0) {
                      return const SaleOrderTable();
                    }
                    return DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadius.lgBorder,
                        border: Border.all(color: _cardBorder),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: _buildOnlineOrdersTab(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOnlineOrdersTab() {
    return SaleEmptyStateCard(
      illustration: const SaleGeometricIllustration(
        circleColor: Color(0xFFE3F2FD),
        shapeColor: Color(0xFF64B5F6),
        shapeIcon: Icons.storefront_outlined,
      ),
      title: 'No Online Orders',
      description: 'Share your Online Store to get orders.',
      buttonLabel: 'Share Store',
      buttonColor: AppColors.error,
      buttonIcon: Icons.share_outlined,
      onPressed: () => showPreviewShareDialog(context),
    );
  }
}
