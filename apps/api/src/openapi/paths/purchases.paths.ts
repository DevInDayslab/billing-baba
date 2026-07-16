import { listExpensesQuerySchema } from '../../modules/purchases/expense.schema';
import { listExpenseCategoriesQuerySchema } from '../../modules/purchases/expense-category.schema';
import {
  listPurchaseDocumentsQuerySchema,
  purchaseLineIdParamSchema,
} from '../../modules/purchases/purchase-document.schema';
import { listPurchaseFaQuerySchema } from '../../modules/purchases/purchase-fa.schema';
import { expenseExamples, purchaseExamples } from '../examples';
import { crudPaths, documentCrudPaths } from '../operations';
import { Schema } from '../schema-names';

export function buildPurchasesPaths() {
  const documents = documentCrudPaths({
    basePath: '/purchases/purchase-documents',
    tag: 'Purchases',
    singular: 'Purchase Document',
    plural: 'Purchase Documents',
    operationKeys: { list: 'PurchaseDocuments', item: 'PurchaseDocument' },
    querySchema: listPurchaseDocumentsQuerySchema,
    querySchemaName: Schema.ListPurchaseDocumentsQuery,
    createBodyRef: Schema.CreatePurchaseDocumentRequest,
    updateBodyRef: Schema.UpdatePurchaseDocumentRequest,
    itemRef: Schema.PurchaseDocumentResponse,
    lineRef: Schema.PurchaseLineResponse,
    createLineRef: Schema.CreatePurchaseLineRequest,
    updateLineRef: Schema.UpdatePurchaseLineRequest,
    lineIdParamSchema: purchaseLineIdParamSchema,
    lineIdParamSchemaName: Schema.PurchaseLineIdParams,
    convertBodyRef: Schema.ConvertPurchaseDocumentRequest,
    finalizeBodyRef: Schema.FinalizePurchaseDocumentRequest,
    createExamples: purchaseExamples.createPurchaseBill,
    lineExamples: purchaseExamples.addLine,
    listDescription:
      'Lists purchase documents (orders, bills, returns). Filter by type, status, party, and date range.',
  });

  const expenses = crudPaths({
    basePath: '/purchases/expenses',
    tag: 'Expenses',
    singular: 'Expense',
    plural: 'Expenses',
    operationKeys: { list: 'Expenses', item: 'Expense' },
    querySchema: listExpensesQuerySchema,
    querySchemaName: Schema.ListExpensesQuery,
    createBodyRef: Schema.CreateExpenseRequest,
    updateBodyRef: Schema.UpdateExpenseRequest,
    itemRef: Schema.ExpenseResponse,
    createExamples: expenseExamples.createExpense,
    listDescription:
      'Lists business expenses. Filter by category, party, date range, amount, and payment mode.',
  });

  const expenseCategories = crudPaths({
    basePath: '/purchases/expense-categories',
    tag: 'Expenses',
    singular: 'Expense Category',
    plural: 'Expense Categories',
    operationKeys: { list: 'ExpenseCategories', item: 'ExpenseCategory' },
    querySchema: listExpenseCategoriesQuerySchema,
    querySchemaName: Schema.ListExpenseCategoriesQuery,
    createBodyRef: Schema.CreateExpenseCategoryRequest,
    updateBodyRef: Schema.UpdateExpenseCategoryRequest,
    itemRef: Schema.ExpenseCategoryResponse,
  });

  const fixedAssets = crudPaths({
    basePath: '/purchases/fixed-asset-purchases',
    tag: 'Purchases',
    singular: 'Fixed Asset Purchase',
    plural: 'Fixed Asset Purchases',
    operationKeys: { list: 'FixedAssetPurchases', item: 'FixedAssetPurchase' },
    querySchema: listPurchaseFaQuerySchema,
    querySchemaName: Schema.ListFixedAssetPurchasesQuery,
    createBodyRef: Schema.CreateFixedAssetPurchaseRequest,
    updateBodyRef: Schema.UpdateFixedAssetPurchaseRequest,
    itemRef: Schema.FixedAssetPurchaseResponse,
    paramName: 'batchId',
    listDescription:
      'Lists fixed asset purchase batches with depreciation schedules.',
  });

  return { ...documents, ...expenses, ...expenseCategories, ...fixedAssets };
}
