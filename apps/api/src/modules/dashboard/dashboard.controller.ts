import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';
import { dashboardQuerySchema } from './dashboard.schema';
import { DashboardService } from './dashboard.service';

export function createDashboardController() {
  const service = new DashboardService();

  return {
    getDashboard: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const query = dashboardQuerySchema.parse(request.query);
        const data = await service.getDashboard(businessId, accountId, query);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid query parameters',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
