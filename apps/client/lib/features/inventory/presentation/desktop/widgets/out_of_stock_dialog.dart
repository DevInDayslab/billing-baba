import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/item_alternatives_provider.dart';
import 'package:billing_baba/features/inventory/data/models/item_alternative_dto.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class OutOfStockDialog extends ConsumerWidget {
  const OutOfStockDialog({
    required this.itemId,
    required this.itemName,
    required this.onSelectAlternative,
    required this.onContinueAnyway,
    super.key,
  });

  final String itemId;
  final String itemName;
  final void Function(RecommendedItemDto) onSelectAlternative;
  final void Function() onContinueAnyway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alternativesAsync = ref.watch(itemAlternativesProvider(itemId));

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWarningMessage(),
                    const SizedBox(height: 24),
                    alternativesAsync.when(
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, stack) {
                        if (kDebugMode) {
                          debugPrint('ALTERNATIVES ERROR: $error');
                        }
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text(
                              'Failed to load alternatives',
                              style: TextStyle(color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        );
                      },
                      data: (alternatives) {
                        if (kDebugMode) {
                          debugPrint(
                            'ALTERNATIVES for $itemId: count=${alternatives.length}',
                          );
                        }
                        return _buildAlternativesList(context, alternatives);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.alertCircle,
              size: 24,
              color: Color(0xFFE53935),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Item Out of Stock',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(LucideIcons.x, size: 20),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildWarningMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFFB74D)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            LucideIcons.packageX,
            size: 20,
            color: Color(0xFFF57C00),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$itemName is currently out of stock.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativesList(
    BuildContext context,
    List<ItemAlternativeDto> alternatives,
  ) {
    if (alternatives.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                LucideIcons.searchX,
                size: 48,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 12),
              Text(
                'No alternatives available',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Alternatives:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        ...alternatives.map((alt) => _buildAlternativeCard(
              context,
              alt.alternativeItem,
            )),
      ],
    );
  }

  Widget _buildAlternativeCard(BuildContext context, AlternativeItemDto item) {
    final hasStock = item.stockQuantity > 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: InkWell(
        onTap: () {
          onSelectAlternative(RecommendedItemDto(
            id: item.id,
            name: item.name,
            barcode: item.barcode,
            brandName: item.brandName,
            categoryName: item.categoryName,
            salePrice: item.salePrice,
            stockQuantity: item.stockQuantity,
          ));
          Navigator.of(context).pop();
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.brandName != null || item.categoryName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          [
                            if (item.brandName != null) item.brandName,
                            if (item.categoryName != null) item.categoryName,
                          ].join(' · '),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: hasStock
                          ? const Color(0xFFE8F5E9)
                          : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          hasStock ? LucideIcons.check : LucideIcons.x,
                          size: 12,
                          color: hasStock
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasStock ? '${item.stockQuantity.toInt()}' : 'Out',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: hasStock
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${item.salePrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              onContinueAnyway();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Continue Anyway'),
          ),
        ],
      ),
    );
  }
}
