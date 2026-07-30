import 'package:billing_baba/features/purchases/models/dto/expense_dto.dart';
import 'package:billing_baba/features/purchases/models/expense_model.dart';
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
      expect(model.status, ExpenseStatus.paid);
      expect(model.balance, 0);
    });

    test('maps loyalty redeemed category variant', () {
      const dto = ExpenseCategoryDto(
        id: 'cat-loyalty',
        name: 'Loyalty Redeemed',
        categoryType: 'indirect',
        isSystem: true,
        expenseCount: 1,
        totalAmount: '100.0000',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toCategoryModel(dto);
      expect(model.variant, ExpenseCategoryVariant.loyaltyRedeemed);
    });

    test('maps payment-in discount category variant', () {
      const dto = ExpenseCategoryDto(
        id: 'cat-discount',
        name: 'Payment-in Discount',
        categoryType: 'indirect',
        isSystem: true,
        expenseCount: 2,
        totalAmount: '50.0000',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toCategoryModel(dto);
      expect(model.variant, ExpenseCategoryVariant.paymentInDiscount);
    });

    test('maps loyalty expense transaction fields', () {
      const dto = ExpenseDto(
        id: '550e8400-e29b-41d4-a716-446655440002',
        categoryId: 'cat-loyalty',
        amount: '150.0000',
        expenseDate: '2026-07-05',
        partyName: 'Ravi Traders',
        categoryName: 'Loyalty Redeemed',
        referenceNumber: 'INV-1001',
        loyaltyPoints: '150.0000',
        sourceReferenceId: 'sale-1',
        sourceReferenceType: 'sale_loyalty_redemption',
        paymentMode: 'cash',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toTransactionModel(dto);
      expect(model.loyaltyPoints, 150);
      expect(model.loyaltyValue, 150);
      expect(model.transactionNo, 'INV-1001');
      expect(model.categoryVariant, ExpenseCategoryVariant.loyaltyRedeemed);
      expect(model.isSyncManaged, isTrue);
    });

    test('maps payment-in discount transaction fields', () {
      const dto = ExpenseDto(
        id: '550e8400-e29b-41d4-a716-446655440003',
        categoryId: 'cat-discount',
        amount: '25.0000',
        expenseDate: '2026-07-05',
        partyName: 'Ravi Traders',
        categoryName: 'Payment-in Discount',
        referenceNumber: 'PAY-1001',
        sourceReferenceId: 'pay-1',
        sourceReferenceType: 'payment_in_discount',
        paymentMode: 'cash',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toTransactionModel(dto);
      expect(model.categoryVariant, ExpenseCategoryVariant.paymentInDiscount);
      expect(model.isSyncManaged, isTrue);
      expect(model.amount, 25);
    });

    test('maps unpaid expense when payment mode is missing', () {
      const dto = ExpenseDto(
        id: '550e8400-e29b-41d4-a716-446655440001',
        categoryId: 'cat-1',
        amount: '500.0000',
        expenseDate: '2026-07-05',
        createdAt: '2026-01-01T00:00:00Z',
        updatedAt: '2026-01-01T00:00:00Z',
      );

      final model = ExpenseMapper.toTransactionModel(dto);
      expect(model.status, ExpenseStatus.pending);
      expect(model.balance, 500);
    });
  });
}
