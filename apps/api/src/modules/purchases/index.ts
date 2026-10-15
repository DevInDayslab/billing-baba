import type { FastifyPluginAsync } from 'fastify';
import { createExpenseRoutes } from './expense.routes';
import { createExpenseCategoryRoutes } from './expense-category.routes';
import { createExpenseItemRoutes } from './expense-item.routes';
import { createPurchaseDocumentRoutes } from './purchase-document.routes';
import { createPurchaseDocumentParseRoutes } from './purchase-document-parse.routes';
import { createPurchaseFaRoutes } from './purchase-fa.routes';

export const purchasesModule: FastifyPluginAsync = async (app) => {
  await app.register(createPurchaseDocumentParseRoutes());
  await app.register(createPurchaseDocumentRoutes(), {
    prefix: '/purchase-documents',
  });
  await app.register(createExpenseRoutes(), { prefix: '/expenses' });
  await app.register(createExpenseCategoryRoutes(), {
    prefix: '/expense-categories',
  });
  await app.register(createExpenseItemRoutes(), {
    prefix: '/expense-items',
  });
  await app.register(createPurchaseFaRoutes(), {
    prefix: '/fixed-asset-purchases',
  });
};
