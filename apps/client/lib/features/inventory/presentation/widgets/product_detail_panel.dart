import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/application/inventory_service.dart';
import 'package:billing_baba/features/inventory/models/godown_model.dart';
import 'package:billing_baba/features/inventory/models/item_image_model.dart';
import 'package:billing_baba/features/inventory/models/item_location_model.dart';
import 'package:billing_baba/features/inventory/models/item_model.dart';
import 'package:billing_baba/features/inventory/models/product_transaction_model.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/adjust_stock_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/edit_item_location_dialog.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_search_field.dart';
import 'package:billing_baba/features/inventory/presentation/widgets/inventory_styles.dart';
import 'package:billing_baba/features/inventory/providers/inventory_brands_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_godowns_provider.dart';
import 'package:billing_baba/features/inventory/providers/inventory_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

const _typeColWidth = 160.0;
const _invoiceColWidth = 110.0;
const _nameColWidth = 120.0;
const _dateColWidth = 140.0;
const _quantityColWidth = 90.0;
const _priceColWidth = 100.0;
const _statusColWidth = 80.0;

const double _minTableWidth =
    _typeColWidth +
    _invoiceColWidth +
    _nameColWidth +
    _dateColWidth +
    _quantityColWidth +
    _priceColWidth +
    _statusColWidth +
    24;

class ProductDetailPanel extends ConsumerWidget {
  const ProductDetailPanel({required this.item, super.key});

  final InventoryItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(productDetailProvider(item.id));
    final displayItem = detailAsync.value ?? item;
    final transactionsAsync = ref.watch(productTransactionsProvider(item.id));
    final stockLevelsAsync = ref.watch(itemStockLevelsProvider(item.id));
    final imagesAsync = ref.watch(itemImagesProvider(item.id));
    final locationsAsync = ref.watch(itemLocationsProvider(item.id));
    final priceHistoryAsync = ref.watch(priceHistoryProvider(item.id));
    final tierPricesAsync = ref.watch(itemTierPricesProvider(item.id));
    final brands = ref.watch(inventoryBrandsProvider).value ?? [];
    final godowns = ref.watch(inventoryGodownsProvider).value ?? [];
    final brandName = brands
        .where((b) => b.id == displayItem.brandId)
        .map((b) => b.name)
        .firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StockSummaryBar(
          item: displayItem,
          brandName: brandName,
          onAdjustStock: () => showAdjustStockDialog(context, item: displayItem),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _DetailSection(
                title: 'STOCK BY GODOWN',
                child: _DetailAsyncContent(
                  asyncValue: stockLevelsAsync,
                  emptyMessage: 'No stock data',
                  onRetry: () => ref.invalidate(itemStockLevelsProvider(item.id)),
                  dataBuilder: (levels) => Column(
                    children: levels
                        .map(
                          (level) => ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Text(level.godownName),
                            trailing: Text(level.quantity),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              _DetailSection(
                title: 'TIER PRICES',
                child: _DetailAsyncContent(
                  asyncValue: tierPricesAsync,
                  emptyMessage: 'No tier prices',
                  onRetry: () => ref.invalidate(itemTierPricesProvider(item.id)),
                  dataBuilder: (tiers) {
                    final currency = NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                    );
                    return Column(
                      children: tiers
                          .map(
                            (tier) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(tier.pricingTier),
                              trailing: Text(currency.format(tier.price)),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              _DetailSection(
                title: 'IMAGES',
                child: _DetailAsyncContent(
                  asyncValue: imagesAsync,
                  emptyMessage: 'No images',
                  onRetry: () => ref.invalidate(itemImagesProvider(item.id)),
                  treatEmptyAsData: true,
                  dataBuilder: (images) =>
                      _ImagesSection(itemId: item.id, images: images),
                ),
              ),
              _DetailSection(
                title: 'LOCATIONS',
                trailing: TextButton(
                  onPressed: () => showEditItemLocationDialog(
                    context,
                    itemId: item.id,
                  ),
                  child: const Text('Add'),
                ),
                child: _DetailAsyncContent(
                  asyncValue: locationsAsync,
                  emptyMessage: 'No locations',
                  onRetry: () => ref.invalidate(itemLocationsProvider(item.id)),
                  dataBuilder: (locations) => _LocationsSection(
                    itemId: item.id,
                    locations: locations,
                    godowns: godowns,
                  ),
                ),
              ),
              _DetailSection(
                title: 'PRICE HISTORY',
                child: _DetailAsyncContent(
                  asyncValue: priceHistoryAsync,
                  emptyMessage: 'No price history',
                  onRetry: () => ref.invalidate(priceHistoryProvider(item.id)),
                  dataBuilder: (records) {
                    final currency = NumberFormat.currency(
                      locale: 'en_IN',
                      symbol: '₹',
                    );
                    return Column(
                      children: records
                          .take(10)
                          .map(
                            (record) => ListTile(
                              dense: true,
                              contentPadding: EdgeInsets.zero,
                              title: Text(currency.format(record.price)),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy').format(record.createdAt),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Text(
                    'TRANSACTIONS',
                    style: InventoryStyles.listHeaderStyle.copyWith(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 220,
                    child: InventorySearchField(
                      hint: 'Search',
                      onChanged: (query) => ref
                          .read(productTransactionSearchQueryProvider.notifier)
                          .query = query,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 280,
                child: transactionsAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (error, _) => const Center(
                    child: Text(
                      'Unable to load transactions',
                      style: InventoryStyles.emptyStateStyle,
                    ),
                  ),
                  data: (transactions) => transactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions found',
                            style: InventoryStyles.emptyStateStyle,
                          ),
                        )
                      : ListView.builder(
                          itemCount: transactions.length,
                          itemBuilder: (context, index) {
                            return _TransactionTableRow(
                              transaction: transactions[index],
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(title, style: InventoryStyles.listHeaderStyle),
              if (trailing != null) ...[
                const Spacer(),
                trailing!,
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          child,
        ],
      ),
    );
  }
}

class _DetailAsyncContent<T> extends StatelessWidget {
  const _DetailAsyncContent({
    required this.asyncValue,
    required this.emptyMessage,
    required this.onRetry,
    required this.dataBuilder,
    this.treatEmptyAsData = false,
  });

  final AsyncValue<T> asyncValue;
  final String emptyMessage;
  final VoidCallback onRetry;
  final Widget Function(T data) dataBuilder;
  final bool treatEmptyAsData;

  @override
  Widget build(BuildContext context) {
    return asyncValue.when(
      loading: () => const Text('Loading...', style: InventoryStyles.emptyStateStyle),
      error: (_, _) => Row(
        children: [
          const Expanded(
            child: Text(
              'Unable to load data',
              style: InventoryStyles.emptyStateStyle,
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
      data: (data) {
        if (!treatEmptyAsData && data is List && data.isEmpty) {
          return Text(emptyMessage, style: InventoryStyles.emptyStateStyle);
        }
        return dataBuilder(data);
      },
    );
  }
}

class _LocationsSection extends ConsumerWidget {
  const _LocationsSection({
    required this.itemId,
    required this.locations,
    required this.godowns,
  });

  final String itemId;
  final List<ItemLocationModel> locations;
  final List<GodownModel> godowns;

  String _godownName(String godownId) {
    return godowns
            .where((godown) => godown.id == godownId)
            .map((godown) => godown.name)
            .firstOrNull ??
        godownId;
  }

  Future<void> _deleteLocation(
    BuildContext context,
    WidgetRef ref,
    ItemLocationModel location,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete location?'),
        content: const Text('Remove this storage location?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final service = await ref.read(inventoryServiceProvider.future);
    await service.deleteItemLocation(location.id);
    ref.invalidate(itemLocationsProvider(itemId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: locations
          .map(
            (location) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                [
                  location.rack,
                  location.shelf,
                ].whereType<String>().where((v) => v.isNotEmpty).join(' / ').isEmpty
                    ? '—'
                    : [
                        location.rack,
                        location.shelf,
                      ].whereType<String>().where((v) => v.isNotEmpty).join(' / '),
              ),
              subtitle: Text(_godownName(location.godownId)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    onPressed: () => showEditItemLocationDialog(
                      context,
                      itemId: itemId,
                      editLocation: location,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18),
                    onPressed: () => _deleteLocation(context, ref, location),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ImagesSection extends ConsumerStatefulWidget {
  const _ImagesSection({required this.itemId, required this.images});

  final String itemId;
  final List<ItemImageModel> images;

  @override
  ConsumerState<_ImagesSection> createState() => _ImagesSectionState();
}

class _ImagesSectionState extends ConsumerState<_ImagesSection> {
  final _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _addImage() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    final service = await ref.read(inventoryServiceProvider.future);
    await service.addItemImage(widget.itemId, imageUrl: url, isPrimary: widget.images.isEmpty);
    _urlController.clear();
    ref.invalidate(itemImagesProvider(widget.itemId));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.images.isEmpty)
          const Text('No images', style: InventoryStyles.emptyStateStyle)
        else
          ...widget.images.map(
            (image) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(image.imageUrl, overflow: TextOverflow.ellipsis),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: () async {
                  final service = await ref.read(inventoryServiceProvider.future);
                  await service.deleteItemImage(widget.itemId, image.id);
                  ref.invalidate(itemImagesProvider(widget.itemId));
                },
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _urlController,
                decoration: const InputDecoration(
                  hintText: 'Image URL',
                  isDense: true,
                ),
              ),
            ),
            TextButton(onPressed: _addImage, child: const Text('Add')),
          ],
        ),
      ],
    );
  }
}

class _StockSummaryBar extends StatelessWidget {
  const _StockSummaryBar({
    required this.item,
    this.brandName,
    this.onAdjustStock,
  });

  final InventoryItem item;
  final String? brandName;
  final VoidCallback? onAdjustStock;

  @override
  Widget build(BuildContext context) {
    final available = item.availableForSale ?? item.quantity;
    final reserved = item.reservedQuantity;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Available for Sale: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                available?.toStringAsFixed(
                      available == available.roundToDouble() ? 0 : 1,
                    ) ??
                    '-',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              Text(
                'RESERVED QUANTITY: ',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                reserved?.toStringAsFixed(
                      reserved == reserved.roundToDouble() ? 0 : 1,
                    ) ??
                    '-',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (onAdjustStock != null)
                TextButton(
                  onPressed: onAdjustStock,
                  child: const Text('Adjust Stock'),
                ),
            ],
          ),
          if (brandName != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Brand: $brandName',
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTableHeader extends StatelessWidget {
  const _TransactionTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(bottom: BorderSide(color: inventoryCardBorder)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 12),
          _HeaderCell(width: _typeColWidth, label: 'TYPE'),
          _HeaderCell(width: _invoiceColWidth, label: 'INVOICE/REF. NO'),
          _HeaderCell(width: _nameColWidth, label: 'NAME'),
          _HeaderCell(
            width: _dateColWidth,
            label: 'DATE',
            showSort: true,
          ),
          _HeaderCell(width: _quantityColWidth, label: 'QUANTITY'),
          _HeaderCell(width: _priceColWidth, label: 'PRICE/ UNIT'),
          _HeaderCell(width: _statusColWidth, label: 'STATUS'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.width,
    required this.label,
    this.showSort = false,
  });

  final double width;
  final String label;
  final bool showSort;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Flexible(
            child: Text(
              label,
              style: InventoryStyles.listHeaderStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.filter_list,
            size: 14,
            color: Colors.grey.shade500,
          ),
          if (showSort) ...[
            const SizedBox(width: 2),
            Icon(
              Icons.arrow_downward,
              size: 12,
              color: Colors.grey.shade600,
            ),
          ],
        ],
      ),
    );
  }
}

class _TransactionTableRow extends StatelessWidget {
  const _TransactionTableRow({required this.transaction});

  final ProductTransaction transaction;

  static final _dateFormat = DateFormat('dd/MM/yyyy hh:mm a');
  static final _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    final dotColor = transaction.isInbound
        ? inventoryPositiveColor
        : inventoryNegativeColor;

    final quantityText = transaction.unit != null
        ? '${_formatQuantity(transaction.quantity)} ${transaction.unit}'
        : _formatQuantity(transaction.quantity);

    final priceText = transaction.pricePerUnit > 0
        ? _currencyFormat.format(transaction.pricePerUnit)
        : '-';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        hoverColor: const Color(0xFFF5F5F5),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: 10,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: inventoryCardBorder)),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              _DataCell(
                width: _typeColWidth,
                child: Text(
                  transaction.typeLabel,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _invoiceColWidth,
                child: Text(
                  transaction.invoiceRefNo,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _nameColWidth,
                child: Text(
                  transaction.partyName,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _dateColWidth,
                child: Text(
                  _dateFormat.format(transaction.date),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DataCell(
                width: _quantityColWidth,
                child: Text(quantityText),
              ),
              _DataCell(
                width: _priceColWidth,
                child: Text(priceText),
              ),
              _DataCell(
                width: _statusColWidth,
                child: Text(
                  transaction.status,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatQuantity(double value) {
    return value == value.roundToDouble()
        ? value.toInt().toString()
        : value.toString();
  }
}

class _DataCell extends StatelessWidget {
  const _DataCell({required this.width, required this.child});

  final double width;
  final Widget child;

  static const _dataStyle = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DefaultTextStyle(style: _dataStyle, child: child),
    );
  }
}
