import type { FastifyPluginAsync } from 'fastify';
import { createIncomeCategoryRoutes } from './income-category.routes';
import { createIncomeItemRoutes } from './income-item.routes';
import { createOtherIncomeRoutes } from './other-income.routes';

export const otherIncomeModule: FastifyPluginAsync = async (app) => {
  await app.register(createOtherIncomeRoutes(), {
    prefix: '/other-incomes',
  });
  await app.register(createIncomeCategoryRoutes(), {
    prefix: '/income-categories',
  });
  await app.register(createIncomeItemRoutes(), {
    prefix: '/income-items',
  });
};
