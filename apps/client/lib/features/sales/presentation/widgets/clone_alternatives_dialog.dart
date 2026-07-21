import 'package:billing_baba/core/theme/app_theme.dart';
import 'package:billing_baba/features/inventory/providers/item_alternatives_provider.dart';
import 'package:billing_baba/features/sales/data/sales_repository.dart';
import 'package:billing_baba/features/sales/models/requests/sales_requests.dart';
import 'package:billing_baba/core/providers/api_client_provider.dart';
import 'package:billing_baba/features/inventory/data/inventory_repository.dart';
import 'package:billing_baba/features/inventory/data/inventory_remote_data_source.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class CloneAlternativesDialog extends ConsumerStatefulWidget {
  const CloneAlternativesDialog({
    required this.invoiceId,
    required this.outOfStockItems,
    required this.repository,
    super.key,
  });

  final String invoiceId;
  final List<OutOfStockItem> outOfStockItems;
  final SalesRepository repository;

  @override
  ConsumerState<CloneAlternativesDialog> createState() =>
      _CloneAlternativesDialogState();
}

class _CloneAlternativesDialogState
    extends ConsumerState<CloneAlternativesDialog> {
  final Map<String, String?> _selectedReplacements = {};
  final Map<String, String> _itemNames = {};
  bool _isCloning = false;

  @override
  void initState() {
    super.initState();
    for (final item in widget.outOfStockItems) {
      _selectedReplacements[item.itemId] = null;
    }
    _loadItemNames();
  }

  Future<void> _loadItemNames() async {
    try {
      final apiClient = await ref.read(apiClientProvider.future);
      final inventoryRepo = InventoryRepository(
        remote: InventoryRemoteDataSource(apiClient.dio),
      );

      for (final outOfStockItem in widget.outOfStockItems) {
        if (outOfStockItem.itemName.isEmpty) {
          try {
            final item = await inventoryRepo.getItem(outOfStockItem.itemId);
            if (mounted) {
              setState(() {
                _itemNames[outOfStockItem.itemId] = item.name;
              });
            }
          } catch (e) {
            if (mounted) {
              setState(() {
                _itemNames[outOfStockItem.itemId] = 'Unknown Item';
              });
            }
          }
        } else {
          _itemNames[outOfStockItem.itemId] = outOfStockItem.itemName;
        }
      }
    } catch (e) {
      // Error loading item names, will show what we have
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700, maxHeight: 700),
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
                    _buildInfoMessage(),
                    const SizedBox(height: 24),
                    const Text(
                      'Select Replacement Items:',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...widget.outOfStockItems.map(
                      (item) => _buildItemReplacementSection(item),
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
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              LucideIcons.copy,
              size: 24,
              color: Color(0xFF1976D2),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Clone with Alternatives',
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

  Widget _buildInfoMessage() {
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
            LucideIcons.info,
            size: 20,
            color: Color(0xFFF57C00),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This will create a new draft invoice with out-of-stock items replaced by your selected alternatives.',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFE65100),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemReplacementSection(OutOfStockItem item) {
    final alternativesAsync =
        ref.watch(itemAlternativesNotifierProvider(item.itemId));
    final itemName = _itemNames[item.itemId] ?? item.itemName;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName.isEmpty ? 'Loading...' : itemName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.packageX,
                              size: 12,
                              color: Color(0xFFE53935),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Out of Stock',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFFE53935),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            alternativesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, stack) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Failed to load alternatives',
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
              data: (alternatives) {
                if (alternatives.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'No alternatives available',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select replacement:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedReplacements[item.itemId],
                      decoration: InputDecoration(
                        hintText: 'Keep original (no replacement)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Keep original (no replacement)'),
                        ),
                        ...alternatives.map(
                          (alt) => DropdownMenuItem<String>(
                            value: alt.alternativeItem.id,
                            child: Text(
                              '${alt.alternativeItem.name} (Stock: ${alt.alternativeItem.stockQuantity.toInt()}) - ₹${alt.alternativeItem.salePrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedReplacements[item.itemId] = value;
                        });
                      },
                    ),
                  ],
                );
              },
            ),
          ],
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
            onPressed: _isCloning ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _isCloning ? null : _handleCloneInvoice,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _isCloning
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text('Clone Invoice'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCloneInvoice() async {
    final replacements = <ItemReplacement>[];
    for (final entry in _selectedReplacements.entries) {
      if (entry.value != null) {
        replacements.add(
          ItemReplacement(
            originalItemId: entry.key,
            replacementItemId: entry.value!,
          ),
        );
      }
    }

    setState(() {
      _isCloning = true;
    });

    try {
      final newInvoice = await widget.repository.cloneWithAlternatives(
        widget.invoiceId,
        replacements,
      );

      if (!mounted) return;

      Navigator.of(context).pop(newInvoice.id);
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isCloning = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to clone invoice: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

class OutOfStockItem {
  const OutOfStockItem({
    required this.itemId,
    required this.itemName,
  });

  final String itemId;
  final String itemName;
}
