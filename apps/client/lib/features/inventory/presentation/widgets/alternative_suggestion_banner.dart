import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/data/models/item_recommendations_dto.dart';
import 'package:billing_baba/features/inventory/providers/item_alternatives_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class AlternativeSuggestionBanner extends ConsumerStatefulWidget {
  const AlternativeSuggestionBanner({
    required this.itemId,
    required this.stockQuantity,
    required this.onReplaceWith,
    super.key,
  });

  final String itemId;
  final double stockQuantity;
  final void Function(RecommendedItemDto item) onReplaceWith;

  @override
  ConsumerState<AlternativeSuggestionBanner> createState() =>
      _AlternativeSuggestionBannerState();
}

class _AlternativeSuggestionBannerState
    extends ConsumerState<AlternativeSuggestionBanner> {
  bool _isDismissed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.stockQuantity > 0 || _isDismissed) {
      return const SizedBox.shrink();
    }

    final recommendationsAsync = ref.watch(
      itemRecommendationsProvider(widget.itemId),
    );

    return recommendationsAsync.when(
      loading: () => Container(
        color: Colors.blue.shade100,
        padding: const EdgeInsets.all(8),
        child: const Text('Loading alternatives...'),
      ),
      error: (error, stack) => Container(
        color: Colors.red.shade100,
        padding: const EdgeInsets.all(8),
        child: Text('Error: $error'),
      ),
      data: (recommendations) {
        final hasManual = recommendations.manuallyConfigured.isNotEmpty;
        final hasSameBrand = recommendations.sameBrandCategory.isNotEmpty;
        final hasSameCategory = recommendations.sameCategory.isNotEmpty;

        if (!hasManual && !hasSameBrand && !hasSameCategory) {
          return const SizedBox.shrink();
        }

        return _buildBanner(
          context,
          recommendations,
          hasManual: hasManual,
          hasSameBrand: hasSameBrand,
          hasSameCategory: hasSameCategory,
        );
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    ItemRecommendationsDto recommendations, {
    required bool hasManual,
    required bool hasSameBrand,
    required bool hasSameCategory,
  }) {
    return Container(
      margin: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        border: Border.all(color: const Color(0xFFFFB74D)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 16,
                color: Color(0xFFF57C00),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Out of stock. Try these alternatives:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _isDismissed = true),
                icon: const Icon(
                  LucideIcons.x,
                  size: 14,
                  color: Color(0xFFF57C00),
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                visualDensity: VisualDensity.compact,
                tooltip: 'Dismiss',
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasManual) ...[
            _buildSection(
              'Configured Alternatives',
              recommendations.manuallyConfigured
                  .map((alt) => _RecommendedItem(
                        id: alt.alternativeItem.id,
                        name: alt.alternativeItem.name,
                        barcode: alt.alternativeItem.barcode,
                        brandName: alt.alternativeItem.brandName,
                        categoryName: alt.alternativeItem.categoryName,
                        salePrice: alt.alternativeItem.salePrice,
                        stockQuantity: alt.alternativeItem.stockQuantity,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (hasSameBrand) ...[
            _buildSection(
              'Same Brand & Category',
              recommendations.sameBrandCategory
                  .map((item) => _RecommendedItem(
                        id: item.id,
                        name: item.name,
                        barcode: item.barcode,
                        brandName: item.brandName,
                        categoryName: item.categoryName,
                        salePrice: item.salePrice,
                        stockQuantity: item.stockQuantity,
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
          ],
          if (hasSameCategory)
            _buildSection(
              'Same Category',
              recommendations.sameCategory
                  .map((item) => _RecommendedItem(
                        id: item.id,
                        name: item.name,
                        barcode: item.barcode,
                        brandName: item.brandName,
                        categoryName: item.categoryName,
                        salePrice: item.salePrice,
                        stockQuantity: item.stockQuantity,
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(String label, List<_RecommendedItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6D4C41),
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) => _buildItemChip(item)).toList(),
        ),
      ],
    );
  }

  Widget _buildItemChip(_RecommendedItem item) {
    final hasStock = item.stockQuantity > 0;
    return InkWell(
      onTap: () {
        final dto = RecommendedItemDto(
          id: item.id,
          name: item.name,
          barcode: item.barcode,
          brandName: item.brandName,
          categoryName: item.categoryName,
          salePrice: item.salePrice,
          stockQuantity: item.stockQuantity,
        );
        widget.onReplaceWith(dto);
        setState(() => _isDismissed = true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: hasStock
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFEBEE),
          border: Border.all(
            color: hasStock
                ? const Color(0xFF66BB6A)
                : const Color(0xFFEF5350),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                item.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '₹${item.salePrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: hasStock
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                hasStock ? '${item.stockQuantity.toInt()}' : 'Out',
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedItem {
  const _RecommendedItem({
    required this.id,
    required this.name,
    required this.salePrice,
    required this.stockQuantity,
    this.barcode,
    this.brandName,
    this.categoryName,
  });

  final String id;
  final String name;
  final String? barcode;
  final String? brandName;
  final String? categoryName;
  final double salePrice;
  final double stockQuantity;
}
