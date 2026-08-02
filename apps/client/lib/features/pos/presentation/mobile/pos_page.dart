import 'dart:async';

import 'package:billing_baba/core/routing/app_routes.dart';
import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_error_mapper.dart';
import 'package:billing_baba/features/inventory/application/inventory_items_provider.dart';
import 'package:billing_baba/features/inventory/models/paginated_inventory_items.dart';
import 'package:billing_baba/features/pos/application/pos_cart_provider.dart';
import 'package:billing_baba/features/pos/application/pos_items_provider.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_barcode_scanner_sheet.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_bottom_bar.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_catalog_body.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_category_rail.dart';
import 'package:billing_baba/features/pos/presentation/mobile/widgets/pos_held_bills_sheet.dart';
import 'package:billing_baba/shared/utils/debouncer.dart';
import 'package:billing_baba/shared/widgets/app_error.dart';
import 'package:billing_baba/shared/widgets/app_loader.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_app_bar.dart';
import 'package:billing_baba/shared/widgets/mobile/mobile_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class MobilePosPage extends ConsumerStatefulWidget {
  const MobilePosPage({super.key});

  @override
  ConsumerState<MobilePosPage> createState() => _MobilePosPageState();
}

class _MobilePosPageState extends ConsumerState<MobilePosPage>
    with SingleTickerProviderStateMixin {
  static const _stripHeight = 160.0;

  final _searchDebouncer = Debouncer();
  String _searchQuery = '';
  String? _selectedCategoryId;
  bool _didRequestInitialRefresh = false;

  bool _scannerOpen = false;
  bool _scannerFullScreen = false;

  late final MobileScannerController _scannerController;
  late final AnimationController _scanLineController;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    unawaited(_scanLineController.repeat(reverse: true));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _didRequestInitialRefresh) return;
      _didRequestInitialRefresh = true;
      unawaited(ref.read(inventoryItemsProvider.notifier).refresh());
    });
  }

  @override
  void dispose() {
    _searchDebouncer.dispose();
    _scanLineController.dispose();
    unawaited(_scannerController.dispose());
    super.dispose();
  }

  void _onBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _openScanner() {
    setState(() {
      _scannerOpen = true;
      _scannerFullScreen = false;
    });
  }

  void _closeScanner() {
    setState(() {
      _scannerOpen = false;
      _scannerFullScreen = false;
    });
  }

  void _expandScanner() {
    setState(() => _scannerFullScreen = true);
  }

  void _collapseScanner() {
    setState(() => _scannerFullScreen = false);
  }

  double _bodyTopOffset(BuildContext context) {
    return MediaQuery.paddingOf(context).top + kToolbarHeight;
  }

  @override
  Widget build(BuildContext context) {
    final inventoryAsync = ref.watch(inventoryItemsProvider).itemsOnly;
    final heldCount = ref.watch(posCartProvider).heldBills.length;
    final bodyTop = _bodyTopOffset(context);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AppColors.background,
          appBar: MobileAppBar(
            title: 'New sale',
            showBackButton: true,
            onBack: () => _onBack(context),
            showBusinessHeader: false,
            showNotification: false,
            // Explicit per POS screen spec (defaults match but must be set).
            // ignore: avoid_redundant_argument_values
            showSettings: true,
            onSettingsTap: () {},
            actions: heldCount > 0
                ? [
                    PosHeldBillsBadge(
                      count: heldCount,
                      onTap: () => unawaited(showPosHeldBillsSheet(context)),
                    ),
                  ]
                : null,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_scannerOpen && !_scannerFullScreen)
                const SizedBox(height: _stripHeight),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.sm,
                      ),
                      child: MobileSearchField(
                        hint: 'Search item or code',
                        onChanged: (value) {
                          _searchDebouncer.run(() {
                            if (!mounted) return;
                            setState(() => _searchQuery = value);
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: inventoryAsync.when(
                        skipLoadingOnReload: true,
                        skipError: inventoryAsync.hasValue,
                        loading: () =>
                            const AppLoader(message: 'Loading items…'),
                        error: (error, _) => AppError(
                          message: InventoryErrorMapper.messageFor(error),
                          onRetry: () =>
                              ref.read(inventoryItemsProvider.notifier).refresh(),
                        ),
                        data: (_) {
                          final filteredItems = ref.watch(
                            posFilteredCatalogProvider(
                              searchQuery: _searchQuery,
                              categoryId: _selectedCategoryId,
                            ),
                          );

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              PosCategoryRail(
                                selectedCategoryId: _selectedCategoryId,
                                onCategorySelected: (categoryId) {
                                  setState(
                                    () => _selectedCategoryId = categoryId,
                                  );
                                },
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: AppSpacing.sm,
                                    right: AppSpacing.lg,
                                  ),
                                  child: PosCatalogBody(
                                    items: filteredItems,
                                    searchQuery: _searchQuery,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              PosBottomBar(onScanTap: _openScanner),
            ],
          ),
        ),
        if (_scannerOpen)
          Positioned(
            top: _scannerFullScreen ? 0 : bodyTop,
            left: 0,
            right: 0,
            bottom: _scannerFullScreen ? 0 : null,
            height: _scannerFullScreen ? null : _stripHeight,
            child: ClipRect(
              child: PosBarcodeScannerLayer(
                key: const ValueKey('pos-barcode-scanner'),
                controller: _scannerController,
                scanLineProgress: _scanLineController,
                isFullScreen: _scannerFullScreen,
                onClose: _closeScanner,
                onExpand: _expandScanner,
                onCollapse: _collapseScanner,
              ),
            ),
          ),
      ],
    );
  }
}
