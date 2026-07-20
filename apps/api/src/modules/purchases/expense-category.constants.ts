export const SYSTEM_EXPENSE_CATEGORY_NAMES = {
  rent: 'Rent',
  utilities: 'Utilities',
  salaries: 'Salaries',
  loyaltyRedeemed: 'Loyalty Redeemed',
  paymentInDiscount: 'Payment-in Discount',
} as const;

export const SYSTEM_EXPENSE_CATEGORIES = [
  { name: SYSTEM_EXPENSE_CATEGORY_NAMES.rent, categoryType: 'direct' as const },
  {
    name: SYSTEM_EXPENSE_CATEGORY_NAMES.utilities,
    categoryType: 'direct' as const,
  },
  {
    name: SYSTEM_EXPENSE_CATEGORY_NAMES.salaries,
    categoryType: 'direct' as const,
  },
  {
    name: SYSTEM_EXPENSE_CATEGORY_NAMES.loyaltyRedeemed,
    categoryType: 'indirect' as const,
  },
  {
    name: SYSTEM_EXPENSE_CATEGORY_NAMES.paymentInDiscount,
    categoryType: 'indirect' as const,
  },
];

export const EXPENSE_SOURCE_TYPES = {
  saleLoyaltyRedemption: 'sale_loyalty_redemption',
  paymentInDiscount: 'payment_in_discount',
} as const;

export type ExpenseSourceType =
  (typeof EXPENSE_SOURCE_TYPES)[keyof typeof EXPENSE_SOURCE_TYPES];
