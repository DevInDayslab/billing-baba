import type { FastifyReply, FastifyRequest } from 'fastify';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { requireAuthContext } from '../inventory/inventory.controller-helpers';
import { gstReportQuerySchema } from './gst-reports.schema';
import { GstReportsService } from './gst-reports.service';

function createService(): GstReportsService {
  const db = getDb();
  if (!db) {
    throw new AppError(
      'DATABASE_NOT_CONFIGURED',
      'Database is not configured',
      503,
    );
  }
  return new GstReportsService(db);
}

async function handle(
  request: FastifyRequest,
  reply: FastifyReply,
  handler: (service: GstReportsService, businessId: string) => Promise<unknown>,
) {
  gstReportQuerySchema.parse(request.query);
  const { businessId } = requireAuthContext(request);
  const service = createService();
  const data = await handler(service, businessId);
  return sendData(reply, data);
}

export function createGstReportsController() {
  return {
    getHsnSummary: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getHsnSummary(id, gstReportQuerySchema.parse(request.query))),
    getSacReport: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getSacReport(id, gstReportQuerySchema.parse(request.query))),
    getGstr1: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getGstr1(id, gstReportQuerySchema.parse(request.query))),
    getGstr2: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getGstr2(id, gstReportQuerySchema.parse(request.query))),
    getGstr3b: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getGstr3b(id, gstReportQuerySchema.parse(request.query))),
    getGstr9: (request: FastifyRequest, reply: FastifyReply) =>
      handle(request, reply, (s, id) => s.getGstr9(id, gstReportQuerySchema.parse(request.query))),
  };
}
