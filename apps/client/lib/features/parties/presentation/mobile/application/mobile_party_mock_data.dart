import 'package:billing_baba/features/parties/models/party_model.dart';

/// Demo parties for mobile UI previews when the live list is empty.
///
// TODO(mobile): Remove mock fallback once party list is fully wired on all devices.
abstract final class MobilePartyMockData {
  static const List<PartyModel> parties = [
    PartyModel(
      id: 'mock-party-1',
      name: 'Sharma Traders',
      phone: '98765 43210',
      balance: 12500,
      gstin: '27AABCS1429B1ZV',
      email: 'sharma@example.com',
      partyGroup: 'Retail',
    ),
    PartyModel(
      id: 'mock-party-2',
      name: 'Gupta Electronics',
      phone: '99887 76655',
      partyType: 'supplier',
      balance: -8400,
      gstin: '09AAACG1234A1Z5',
      email: 'gupta@example.com',
    ),
    PartyModel(
      id: 'mock-party-3',
      name: 'Patel & Sons',
      phone: '91234 56789',
      partyType: 'both',
      balance: 3200,
      partyGroup: 'Wholesale',
    ),
    PartyModel(
      id: 'mock-party-4',
      name: 'City Mart',
      phone: '90000 11122',
      isActive: false,
    ),
    PartyModel(
      id: 'mock-party-5',
      name: 'National Distributors',
      phone: '95555 44433',
      partyType: 'supplier',
      balance: -25600,
      gstin: '24AABCN9876C1Z8',
    ),
  ];
}
