import 'package:billing_baba/features/business/models/business_model.dart';

/// Data access layer for businesses. Returns mock data until backend integration.
class BusinessRepository {
  static final List<BusinessModel> _mockBusinesses = [
    BusinessModel(
      id: 'biz-001',
      name: 'Sharma General Store',
      ownerName: 'Rajesh Sharma',
      gstin: '27AABCS1429B1Z5',
      phone: '+91 98765 43210',
      lastOpenedAt: DateTime(2026, 6, 28, 14, 30),
    ),
    BusinessModel(
      id: 'biz-002',
      name: 'Patel Electronics',
      ownerName: 'Amit Patel',
      gstin: '24AAACP1234A1ZV',
      phone: '+91 91234 56789',
      lastOpenedAt: DateTime(2026, 6, 25, 9, 15),
    ),
    BusinessModel(
      id: 'biz-003',
      name: 'Green Valley Pharmacy',
      ownerName: 'Priya Nair',
      gstin: '32AABCG1234F1Z2',
      phone: '+91 99887 76655',
      lastOpenedAt: DateTime(2026, 6, 20, 18, 45),
      isOfflineReady: false,
    ),
    BusinessModel(
      id: 'biz-004',
      name: 'Kumar Auto Parts',
      ownerName: 'Vikram Kumar',
      gstin: '09AABCK5678D1Z3',
      phone: '+91 97654 32109',
      lastOpenedAt: DateTime(2026, 6, 15, 11),
      isShared: true,
    ),
    BusinessModel(
      id: 'biz-005',
      name: 'City Fashion Hub',
      ownerName: 'Neha Gupta',
      gstin: '07AABCN9012E1Z8',
      phone: '+91 96543 21098',
      lastOpenedAt: DateTime(2026, 6, 10, 16, 20),
      isShared: true,
    ),
  ];

  Future<List<BusinessModel>> getBusinesses() async {
    return List<BusinessModel>.from(_mockBusinesses);
  }

  Future<List<BusinessModel>> searchBusinesses(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) {
      return getBusinesses();
    }

    final businesses = await getBusinesses();
    return businesses
        .where(
          (business) =>
              business.name.toLowerCase().contains(normalized) ||
              business.ownerName.toLowerCase().contains(normalized) ||
              business.gstin.toLowerCase().contains(normalized) ||
              business.phone.contains(normalized),
        )
        .toList();
  }

  Future<void> restoreBackup() async {
    // TODO(team): Open restore backup flow when backend is ready.
  }

  Future<void> createBusiness() async {
    // TODO(team): Navigate to create business flow when screen is ready.
  }
}
