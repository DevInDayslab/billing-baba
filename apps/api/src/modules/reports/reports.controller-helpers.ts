import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError, type z } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import type { PaginationMeta } from '../../shared/http/pagination';
import { sendData } from '../../shared/http/response';
import { sendCsv } from '../../shared/reporting/csv-export';
import {
  formatZodError,
  requireAuthContext,
} from '../inventory/inventory.controller-helpers';

export function handleReportError(error: unknown): never {
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

type PaginatedResult = {
  data: object;
  meta: PaginationMeta;
};

export async function handlePaginatedReport(
  request: FastifyRequest,
  reply: FastifyReply,
  schema: z.ZodTypeAny,
  fetch: (
    businessId: string,
    accountId: string,
    query: any,
  ) => Promise<PaginatedResult>,
  csvFilename: string,
): Promise<FastifyReply> {
  try {
    const { accountId, businessId } = requireAuthContext(request);
    const query = schema.parse(request.query) as {
      format?: 'json' | 'csv';
    };
    const result = await fetch(businessId, accountId, query);

    if (query.format === 'csv') {
      const data = result.data as { rows?: Record<string, unknown>[] };
      const rows = data.rows ?? [];
      return sendCsv(reply, csvFilename, rows);
    }

    return reply.status(200).send(result);
  } catch (error) {
    handleReportError(error);
  }
}

export async function handleDataReport<T extends Record<string, unknown>>(
  request: FastifyRequest,
  reply: FastifyReply,
  schema: z.ZodTypeAny,
  fetch: (businessId: string, accountId: string, query: any) => Promise<T>,
): Promise<FastifyReply> {
  try {
    const { accountId, businessId } = requireAuthContext(request);
    const query = schema.parse(request.query);
    const data = await fetch(businessId, accountId, query);
    return sendData(reply, data);
  } catch (error) {
    handleReportError(error);
  }
}
