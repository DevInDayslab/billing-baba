import 'package:billing_baba/features/crm/domain/models/contact.dart';

/// Local seed contacts for CRM UI testing when the SQLite table is empty.
abstract final class ContactMockData {
  static List<Contact> contactsFor(String businessId) {
    return _entries
        .map(
          (entry) => Contact(
            id: entry.id,
            businessId: businessId,
            name: entry.name,
            firstName: entry.firstName,
            lastName: entry.lastName,
            accountName: entry.accountName,
            phone: entry.phone,
            email: entry.email,
            assignedTo: entry.assignedTo,
            title: entry.title,
            syncStatus: 'synced',
            createdAt: entry.createdAt,
            updatedAt: entry.createdAt,
          ),
        )
        .toList();
  }

  static final _entries = [
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000001',
      name: 'Rahul Sharma',
      firstName: 'Rahul',
      lastName: 'Sharma',
      accountName: 'ABC Traders',
      phone: '+91 98765 43210',
      email: 'rahul@abctraders.com',
      assignedTo: 'Saksham Koch',
      title: 'Purchase Manager',
      createdAt: _july(2),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000002',
      name: 'Priya Mehta',
      firstName: 'Priya',
      lastName: 'Mehta',
      accountName: 'XYZ Enterprises',
      phone: '+91 87654 32109',
      email: 'priya@xyz.com',
      assignedTo: 'Priya Mehta',
      title: 'Director',
      createdAt: _july(4),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000003',
      name: 'Amit Verma',
      firstName: 'Amit',
      lastName: 'Verma',
      accountName: 'Verma and Sons',
      phone: '+91 76543 21098',
      email: 'amit@verma.com',
      assignedTo: 'Amit Verma',
      title: 'Owner',
      createdAt: _july(6),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000004',
      name: 'Sunita Patel',
      firstName: 'Sunita',
      lastName: 'Patel',
      phone: '+91 65432 10987',
      email: 'sunita@gmail.com',
      assignedTo: 'Saksham Koch',
      createdAt: _july(8),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000005',
      name: 'Ravi Kumar',
      firstName: 'Ravi',
      lastName: 'Kumar',
      accountName: 'Kumar Distributors',
      phone: '+91 54321 09876',
      email: 'ravi@kumar.com',
      assignedTo: 'Priya Mehta',
      title: 'Sales Head',
      createdAt: _july(10),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000006',
      name: 'Neha Gupta',
      firstName: 'Neha',
      lastName: 'Gupta',
      accountName: 'Gupta Wholesale',
      phone: '+91 99887 76655',
      email: 'neha@gupta.com',
      assignedTo: 'Amit Verma',
      title: 'Accounts',
      createdAt: _july(12),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000007',
      name: 'Vikram Singh',
      firstName: 'Vikram',
      lastName: 'Singh',
      accountName: 'Singh Retail',
      phone: '+91 88776 65544',
      email: 'vikram@singh.com',
      assignedTo: 'Saksham Koch',
      createdAt: _june(28),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000008',
      name: 'Anjali Nair',
      firstName: 'Anjali',
      lastName: 'Nair',
      accountName: 'Nair Enterprises',
      phone: '+91 77665 54433',
      email: 'anjali@nair.com',
      assignedTo: 'Priya Mehta',
      createdAt: _july(14),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000009',
      name: 'Deepak Joshi',
      firstName: 'Deepak',
      lastName: 'Joshi',
      phone: '+91 66554 43322',
      email: 'deepak@gmail.com',
      assignedTo: 'Amit Verma',
      createdAt: _july(1),
    ),
    _MockContactEntry(
      id: 'a1000001-0000-4000-8000-000000000010',
      name: 'Kavita Sharma',
      firstName: 'Kavita',
      lastName: 'Sharma',
      accountName: 'Sharma Textiles',
      phone: '+91 55443 32211',
      email: 'kavita@sharma.com',
      assignedTo: 'Saksham Koch',
      title: 'Procurement',
      createdAt: _july(3),
    ),
  ];
}

class _MockContactEntry {
  const _MockContactEntry({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.accountName,
    required this.phone,
    this.email,
    this.assignedTo,
    this.title,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? accountName;
  final String phone;
  final String? email;
  final String? assignedTo;
  final String? title;
  final DateTime createdAt;
}

DateTime _july(int day) => DateTime.utc(2026, 7, day, 10);

DateTime _june(int day) => DateTime.utc(2026, 6, day, 10);
