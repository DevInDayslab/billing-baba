import 'package:billing_baba/features/parties/models/party_model.dart';

/// Seed catalog for report UI until Drift repositories are wired.
abstract final class PartyCatalog {
  static const partyNames = [
    'Sharma Traders',
    'Patel Electronics',
    'Gupta General Store',
    'Mehta Hardware',
    'Singh & Sons',
    'Kumar Agencies',
    'Reddy Mart',
    'Joshi Distributors',
    'Verma Enterprises',
    'Agarwal Textiles',
    'Bansal Pharma',
    'Chopra Foods',
  ];

  static const _balances = [
    18500.0,
    -12400.0,
    0.0,
    28750.0,
    -5600.0,
    9200.0,
    -18300.0,
    4500.0,
    0.0,
    -7200.0,
    15600.0,
    -3400.0,
  ];

  static const _activeFlags = [
    true,
    true,
    true,
    false,
    true,
    false,
    true,
    true,
    false,
    true,
    true,
    false,
  ];

  static const _phones = [
    '+91 98765 43210',
    '+91 91234 56789',
    '+91 99887 76655',
    '+91 90123 45678',
    '+91 97654 32109',
    '+91 93456 78901',
    '+91 98901 23456',
    '+91 94567 89012',
    '+91 92345 67890',
    '+91 96789 01234',
    '+91 98123 45670',
    '+91 95678 90123',
  ];

  static final List<PartyModel> parties = [
    for (var i = 0; i < partyNames.length; i++)
      PartyModel(
        id: 'party-${i + 1}',
        name: partyNames[i],
        phone: _phones[i % _phones.length],
        balance: _balances[i % _balances.length],
        isActive: _activeFlags[i % _activeFlags.length],
      ),
  ];
}
