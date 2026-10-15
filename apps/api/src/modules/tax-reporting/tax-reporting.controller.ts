import type { FastifyReply, FastifyRequest } from 'fastify';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { buildPaginationMeta } from '../../shared/http/pagination';
import { sendData } from '../../shared/http/response';
import { requireAuthContext } from '../inventory/inventory.controller-helpers';
import { taxReportQuerySchema } from './tax-reporting.schema';
import { TaxReportingService } from './tax-reporting.service';

function createService(): TaxReportingService {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return new TaxReportingService(db);
}

export function createTaxReportingController() {
  return {
    getGstRegister: async (request: FastifyRequest, reply: FastifyReply) => {
      const query = taxReportQuerySchema.parse(request.query);
      const { businessId } = requireAuthContext(request);
      const service = createService();
      const { envelope, total } = await service.getGstRegister(
        businessId,
        query,
      );
      return reply.send({
        data: envelope,
        meta: buildPaginationMeta({
          page: query.page,
          limit: query.limit,
          total,
        }),
      });
    },
    getGstRateSummary: async (request: FastifyRequest, reply: FastifyReply) => {
      const query = taxReportQuerySchema.parse(request.query);
      const { businessId } = requireAuthContext(request);
      const service = createService();
      const envelope = await service.getGstRateSummary(businessId, query);
      return sendData(reply, envelope);
    },
    getTdsPayable: async (request: FastifyRequest, reply: FastifyReply) =>
      sendData(
        reply,
        await createService().getWithholdingReport(
          requireAuthContext(request).businessId,
          taxReportQuerySchema.parse(request.query),
          'tds',
          'payable',
        ),
      ),
    getTdsReceivable: async (request: FastifyRequest, reply: FastifyReply) =>
      sendData(
        reply,
        await createService().getWithholdingReport(
          requireAuthContext(request).businessId,
          taxReportQuerySchema.parse(request.query),
          'tds',
          'receivable',
        ),
      ),
    getTcsReceivable: async (request: FastifyRequest, reply: FastifyReply) =>
      sendData(
        reply,
        await createService().getWithholdingReport(
          requireAuthContext(request).businessId,
          taxReportQuerySchema.parse(request.query),
          'tcs',
          'receivable',
        ),
      ),
    getForm27eq: async (request: FastifyRequest, reply: FastifyReply) =>
      sendData(
        reply,
        await createService().getForm27eq(
          requireAuthContext(request).businessId,
          taxReportQuerySchema.parse(request.query),
        ),
      ),
  };
}
