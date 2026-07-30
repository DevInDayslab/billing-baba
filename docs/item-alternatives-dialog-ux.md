# Item Alternatives - Dialog UX Implementation

## Overview

Changed the out-of-stock alternatives UX from a post-confirmation banner to an immediate dialog when selecting out-of-stock items.

## Implementation Summary

### 1. Created OutOfStockDialog Widget

**File:** `apps/client/lib/features/inventory/presentation/widgets/out_of_stock_dialog.dart`

**Features:**
- Modal dialog that appears immediately when user selects an out-of-stock item
- Shows warning message with item name
- Lists alternatives in 3 categories (priority order):
  1. Configured Alternatives (manually set)
  2. Same Brand & Category
  3. Same Category
- Each alternative shows:
  - Item name
  - Stock status chip (green if in stock, red if out)
  - Sale price
- User actions:
  - Tap alternative → replaces selected item and closes dialog
  - "Continue Anyway" → keeps original item despite being out of stock
  - "Cancel" → closes dialog without adding item

### 2. Removed AlternativeSuggestionBanner Integration

**Files Modified:**
- `apps/client/lib/features/sales/presentation/widgets/sale_line_items_table.dart`
- `apps/client/lib/features/sales/presentation/widgets/sale_order_line_items_table.dart`
- `apps/client/lib/features/sales/presentation/widgets/credit_note_line_items_table.dart`

**Changes:**
- Removed `AlternativeSuggestionBanner` import
- Removed `_buildLineItemsWithBanners()` method
- Restored simple `for` loop for line item rows in Column
- Removed banner widgets that appeared after confirmed items

### 3. Added Dialog Trigger on Item Selection

**Implementation Pattern (applied to all 3 tables):**

```dart
Future<void> _handleItemSelected(
  int index,
  SaleItemOption catalogItem,
) async {
  final notifier = ref.read(formProvider.notifier);
  
  // Check if item is out of stock
  if (catalogItem.stock == 0) {
    if (!mounted) return;
    
    await showDialog<void>(
      context: context,
      builder: (context) => OutOfStockDialog(
        itemId: catalogItem.id!,
        itemName: catalogItem.name,
        onSelectAlternative: (alternative) {
          notifier.selectCatalogItem(
            index,
            SaleItemOption(
              id: alternative.id,
              name: alternative.name,
              salePrice: alternative.salePrice,
              // ... other fields
            ),
          );
        },
        onContinueAnyway: () {
          notifier.selectCatalogItem(index, catalogItem);
        },
      ),
    );
  } else {
    // Item has stock, proceed normally
    notifier.selectCatalogItem(index, catalogItem);
  }
}
```

**Integration:**
- Added `onItemSelected` parameter to `_LineItemRow` widget
- Pass `_handleItemSelected` method as callback from parent state
- ItemNameAutocompleteField calls this handler when item selected

## User Experience Flow

### Old Flow (Banner):
1. User selects item
2. User confirms line item (clicks checkmark)
3. Banner appears below confirmed row if stock = 0
4. User clicks alternative chip in banner
5. Line item updates with new item

### New Flow (Dialog):
1. User selects item
2. **If stock = 0: Dialog appears immediately**
3. User chooses alternative OR continues anyway OR cancels
4. Line item populated based on choice
5. **If stock > 0: Proceeds normally without dialog**

## Benefits of Dialog Approach

1. **Immediate Feedback:** User knows stock status right away
2. **Prevents Errors:** User can't proceed without acknowledging stock issue
3. **Cleaner UI:** No persistent banners cluttering the table
4. **Better Mobile UX:** Dialog works better on smaller screens than inline banners
5. **Proactive:** Stops user before committing to out-of-stock item

## Files Created/Modified

### Created:
- `apps/client/lib/features/inventory/presentation/widgets/out_of_stock_dialog.dart`
- `docs/item-alternatives-dialog-ux.md`

### Modified:
- `apps/client/lib/features/sales/presentation/widgets/sale_line_items_table.dart`
- `apps/client/lib/features/sales/presentation/widgets/sale_order_line_items_table.dart`
- `apps/client/lib/features/sales/presentation/widgets/credit_note_line_items_table.dart`

### Removed:
- AlternativeSuggestionBanner integration (widget file itself remains but unused)

## Testing Checklist

- [ ] Dialog appears when selecting out-of-stock item in Invoice
- [ ] Dialog appears when selecting out-of-stock item in Estimate/Quotation
- [ ] Dialog appears when selecting out-of-stock item in Credit Note
- [ ] Alternatives load correctly (3 categories)
- [ ] Tapping alternative replaces item correctly
- [ ] "Continue Anyway" keeps original item
- [ ] "Cancel" doesn't add item to line
- [ ] Dialog doesn't appear for items with stock > 0
- [ ] Loading state shows while fetching recommendations
- [ ] Error state displays if API fails
- [ ] Empty state shows when no alternatives available
- [ ] Stock chips show correct color (green/red)
- [ ] Dialog is responsive on mobile

## Backend Requirements

Uses existing endpoint:
- `GET /api/v1/inventory/items/{itemId}/alternatives/recommendations`

No backend changes required - all API endpoints already implemented in Phase 1.

## Future Enhancements

- Add "Don't show again for this item" checkbox
- Remember user's "Continue Anyway" choice per item
- Show reason why item is out of stock (if available)
- Add quick actions: "Order More", "Notify When Available"
- Batch selection mode: show all out-of-stock items at once before finalizing invoice
