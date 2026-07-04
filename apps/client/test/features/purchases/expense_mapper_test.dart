import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/mappers/expense_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ExpenseMapper', () {
    test('maps category with type and totals', () {
      const dto = ExpenseCategoryDto(
        id: 'cat-1',
        name: 'Rent',
        categoryType: 'indirect',
        isSystem: true,
        expenseCount: 3,
        totalAmount: '1500.0000',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toCategoryModel(dto);
      expect(model.name, 'Rent');
      expect(model.type.name, 'indirect');
      expect(model.totalAmount, 1500);
    });

    test('maps expense transaction with party name', () {
      const dto = ExpenseDto(
        id: '550e8400-e29b-41d4-a716-446655440000',
        categoryId: 'cat-1',
        amount: '250.0000',
        expenseDate: '2026-07-05',
        partyName: 'Acme Supplies',
        categoryName: 'Utilities',
        paymentMode: 'cash',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toTransactionModel(dto);
      expect(model.party, 'Acme Supplies');
      expect(model.amount, 250);
    });
  });
}
