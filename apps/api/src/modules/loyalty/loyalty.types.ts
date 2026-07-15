export type PartyType = 'customer' | 'supplier' | 'both';

export type LoyaltyTransactionType = 'earn' | 'redeem';

export type PartyLoyaltyBalanceRecord = {
  party_id: string;
  points_earned: string;
  points_available: string;
};

export type LoyaltyTransactionRecord = {
  id: string;
  party_id: string;
  transaction_type: LoyaltyTransactionType;
  points: string;
  balance_after: string;
  reference_id: string | null;
  reference_type: string | null;
  spend_amount: string | null;
  rupees_per_point: string | null;
  description: string | null;
  created_at: string;
};

export type LoyaltyRulesRecord = {
  id: string | null;
  rupees_per_point: string;
  is_active: boolean;
  updated_at: string | null;
};

export type SaleLoyaltyResult = {
  earned_points: string;
  redeemed_points: string;
  points_available: string;
};

export type LoyaltyBalanceRow = {
  id: string;
  partyId: string;
  pointsEarned: string;
  pointsAvailable: string;
};

export type LoyaltyRulesRow = {
  id: string;
  rupeesPerPoint: string;
  isActive: boolean;
  updatedAt: Date;
};
