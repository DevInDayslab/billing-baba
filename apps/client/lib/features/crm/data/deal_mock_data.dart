import 'package:billing_baba/features/crm/domain/models/deal.dart';

/// Local seed deals for CRM Kanban UI testing when the SQLite table is empty.
abstract final class DealMockData {
  static List<Deal> dealsFor(String businessId) {
    return _entries
        .map(
          (entry) => Deal(
            id: entry.id,
            businessId: businessId,
            name: entry.name,
            stage: entry.stage,
            accountName: entry.accountName,
            assignedTo: entry.assignedTo,
            amount: entry.amount,
            expectedCloseDate: entry.expectedCloseDate,
            syncStatus: 'synced',
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ),
        )
        .toList();
  }

  static final List<_MockDealEntry> _entries = [
    for (var i = 1; i <= 4; i++)
      _MockDealEntry(
        id: 'd1000001-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        name: 'Deal $i',
        stage: DealStage.qualification,
        accountName: 'Acme Retail $i',
        assignedTo: 'Saksham Kochhar',
        amount: 50000 + (i * 50000),
        expectedCloseDate: DateTime(2026, 8, 10 + i),
        createdAt: _july(i),
      ),
    for (var i = 5; i <= 8; i++)
      _MockDealEntry(
        id: 'd1000002-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        name: 'Deal $i',
        stage: DealStage.needsAnalysis,
        accountName: 'Acme Retail $i',
        assignedTo: 'Saksham Kochhar',
        amount: 80000 + (i * 20000),
        expectedCloseDate: DateTime(2026, 8, 20 + i),
        createdAt: _july(i + 2),
      ),
    for (var i = 9; i <= 12; i++)
      _MockDealEntry(
        id: 'd1000003-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        name: 'Deal $i',
        stage: DealStage.identifyDecisionMakers,
        accountName: 'Acme Retail $i',
        assignedTo: 'Saksham Kochhar',
        amount: 120000 + (i * 10000),
        expectedCloseDate: DateTime(2026, 9, i),
        createdAt: _july(i + 4),
      ),
    for (var i = 13; i <= 16; i++)
      _MockDealEntry(
        id: 'd1000004-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        name: 'Deal $i',
        stage: DealStage.negotiationReview,
        accountName: 'Acme Retail $i',
        assignedTo: 'Saksham Kochhar',
        amount: 150000 + (i * 15000),
        expectedCloseDate: DateTime(2026, 9, 10 + i),
        createdAt: _july(i + 6),
      ),
    for (var i = 17; i <= 20; i++)
      _MockDealEntry(
        id: 'd1000005-0000-4000-8000-${i.toString().padLeft(12, '0')}',
        name: 'Deal $i',
        stage: DealStage.closedWon,
        accountName: 'Acme Retail $i',
        assignedTo: 'Saksham Kochhar',
        amount: 180000 + (i * 10000),
        expectedCloseDate: DateTime(2026, 9, i),
        createdAt: _july(i + 8),
      ),
  ];
}

class _MockDealEntry {
  const _MockDealEntry({
    required this.id,
    required this.name,
    required this.stage,
    required this.accountName,
    required this.assignedTo,
    required this.amount,
    required this.expectedCloseDate,
    required this.createdAt,
  });

  final String id;
  final String name;
  final DealStage stage;
  final String accountName;
  final String assignedTo;
  final double amount;
  final DateTime expectedCloseDate;
  final DateTime createdAt;
}

DateTime _july(int day) => DateTime.utc(2026, 7, day.clamp(1, 28));
