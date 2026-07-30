# Item Alternatives - Phase 3: Out of Stock Suggestions

## Overview

Phase 3 adds intelligent alternative item suggestions when a user selects an out-of-stock item in invoices, estimates, or other sales documents. The system automatically displays a banner below the line item with recommended alternatives based on:

1. **Manually configured alternatives** (from Phase 1 & 2)
2. **Same brand & category** items
3. **Same category** items

## Backend Implementation

### API Endpoint
The recommendations endpoint is already implemented:

**GET** `/api/v1/inventory/items/{itemId}/alternatives/recommendations`

### Response Structure
```json
{
  "data": {
    "manually_configured": [
      {
        "id": "uuid",
        "item_id": "uuid",
        "alternative_item_id": "uuid",
        "alternative_item": {
          "id": "uuid",
          "name": "Item Name",
          "barcode": "123456",
          "brand_name": "Brand",
          "category_name": "Category",
          "sale_price": "150.00",
          "stock_quantity": 5.0
        }
      }
    ],
    "same_brand_category": [
      {
        "id": "uuid",
        "name": "Similar Item",
        "barcode": "789012",
        "brand_name": "Same Brand",
        "category_name": "Same Category",
        "sale_price": "160.00",
        "stock_quantity": 10.0
      }
    ],
    "same_category": [
      {
        "id": "uuid",
        "name": "Category Item",
        "barcode": "345678",
        "brand_name": "Different Brand",
        "category_name": "Same Category",
        "sale_price": "140.00",
        "stock_quantity": 3.0
      }
    ]
  }
}
```

## Flutter Client Implementation

### Components Created

#### 1. DTOs (Already Existed)
- **`RecommendedItemDto`**: Represents a recommended alternative item
- **`ItemRecommendationsDto`**: Container for all three recommendation categories

Location: `apps/client/lib/features/inventory/data/models/item_recommendations_dto.dart`

#### 2. Repository (Already Existed)
- **`ItemAlternativesRepository.fetchRecommendations(itemId)`**: Fetches recommendations from API

Location: `apps/client/lib/features/inventory/data/item_alternatives_repository.dart`

#### 3. Provider (Already Existed)
- **`itemRecommendationsProvider(itemId)`**: Riverpod provider for recommendations

Location: `apps/client/lib/features/inventory/providers/item_alternatives_provider.dart`

#### 4. Widget (New)
**`AlternativeSuggestionBanner`**

Location: `apps/client/lib/features/inventory/presentation/widgets/alternative_suggestion_banner.dart`

**Props:**
- `itemId: String` - The out-of-stock item ID
- `stockQuantity: double` - Current stock quantity
- `onReplaceWith: void Function(RecommendedItemDto item)` - Callback when user selects an alternative

**Behavior:**
- Only renders if `stockQuantity == 0`
- Dismissible via X button
- Shows recommendations in priority order:
  1. Configured Alternatives (manually set)
  2. Same Brand & Category
  3. Same Category
- Each suggestion shows: name, price, stock level
- Tapping a suggestion calls `onReplaceWith()` and auto-dismisses

**Styling:**
- Orange warning banner (out-of-stock color scheme)
- Chip-based suggestions with color-coded stock status:
  - Green: In stock
  - Red: Out of stock
- Compact, non-intrusive design

### Integration

#### Modified Files

**`sale_line_items_table.dart`**
- Added `_buildLineItemsWithBanners()` method
- Integrates banner after each confirmed line item
- Fetches inventory item to check stock quantity
- Replaces item on selection with `updateLineItem()`

**How it works:**
1. For each line item, check if it's confirmed and has an `itemId`
2. Fetch the inventory item to get current stock quantity
3. If stock is 0, render `AlternativeSuggestionBanner`
4. When user taps an alternative, update the line item with:
   - New item ID
   - New item name
   - New sale price
   - Preserve: quantity, discount, tax

## User Experience

### Workflow

1. **User adds item to invoice**
   - Item is selected via autocomplete
   - Line item row appears

2. **User confirms the line item**
   - Presses Enter or tabs to next field
   - Item is marked as "confirmed"

3. **Banner appears (if out of stock)**
   - System checks stock quantity
   - If quantity = 0, banner shows below line item
   - Banner displays up to 3 categories of alternatives

4. **User reviews alternatives**
   - Sees name, price, and stock for each
   - Can tap any suggestion to replace

5. **User selects alternative**
   - Taps on a suggested item chip
   - Line item updates with new item details
   - Banner auto-dismisses
   - Quantity, discount, tax remain unchanged

### Design Principles

- **Non-blocking**: User can ignore and continue
- **Contextual**: Only shows for out-of-stock items
- **Smart**: Prioritizes configured alternatives first
- **Dismissible**: X button to hide permanently (per line item)
- **Automatic**: No manual refresh needed

## Future Enhancements (Phase 4+)

1. **POS Integration**: Apply same logic to POS screens
2. **Estimates Integration**: Add to estimate/quotation forms
3. **Credit Note Integration**: Support for credit note workflows
4. **Delivery Challan**: Add to delivery challan forms
5. **Purchase Order Suggestions**: Suggest reorder when stock is low
6. **Smart Ranking**: ML-based suggestion ranking based on:
   - Historical sales patterns
   - Profit margins
   - Customer preferences
7. **Bulk Replace**: Replace all out-of-stock items in one click
8. **Preview Before Replace**: Show what will change before confirming

## Testing Checklist

- [ ] Banner appears when item stock = 0
- [ ] Banner does NOT appear when item stock > 0
- [ ] Manually configured alternatives show first
- [ ] Same brand & category alternatives show second
- [ ] Same category alternatives show third
- [ ] Tapping alternative updates line item correctly
- [ ] Quantity, discount, tax preserved after replace
- [ ] Dismiss button hides banner
- [ ] Banner re-appears if item changed back to out-of-stock
- [ ] Multiple line items can have banners simultaneously
- [ ] Banner scrolls with line items
- [ ] Mobile/desktop responsive
- [ ] API errors don't crash UI
- [ ] Loading state handled gracefully

## Architecture Decisions

### Why Not Auto-Replace?
We explicitly chose NOT to auto-replace items to:
- Maintain user control
- Prevent accidental substitutions
- Allow users to verify alternatives
- Support manual stock adjustment workflows

### Why Show Banner After Confirmation?
- Reduces visual clutter during data entry
- Confirms user intent before suggesting
- Separates "add item" from "optimize item" workflows

### Why Three Recommendation Tiers?
- **Configured**: Business owner knows best
- **Same Brand & Category**: Highest relevance
- **Same Category**: Fallback option
- Covers 90%+ of real-world scenarios

## Performance Considerations

- Recommendations fetched lazily (only when needed)
- Cached via Riverpod (no redundant API calls)
- Banner renders conditionally (minimal overhead)
- Inventory items cached separately

## Related Documentation

- [Phase 1: Item Alternatives Data Layer](./item-alternatives-phase1.md)
- [Phase 2: Item Master UI](./item-alternatives-phase2.md)
- [Design System](./03-design-system.md)
- [Architecture: Offline-First](./02-architecture.md)
