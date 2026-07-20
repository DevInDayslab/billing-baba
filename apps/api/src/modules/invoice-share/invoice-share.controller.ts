import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { InvoiceShareService } from './invoice-share.service';
import {
  invoiceIdParamSchema,
  invoiceShareTokenParamSchema,
  partyIdParamSchema,
  sendPaymentReminderBodySchema,
  sendSaleInvoiceBodySchema,
} from './invoice-share.utils';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

function requireAuthContext(request: FastifyRequest): {
  accountId: string;
  businessId: string;
} {
  const accountId = request.accountId;
  const businessId = request.businessId;
  if (!accountId || !businessId) {
    throw new AppError(
      'UNAUTHORIZED',
      'Account or business not found in token',
      401,
    );
  }
  return { accountId, businessId };
}

export function createInvoiceShareController(config: AppConfig) {
  const service = new InvoiceShareService(config);

  return {
    getPublicByToken: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { token } = invoiceShareTokenParamSchema.parse(request.params);
        const data = await service.getPublicInvoice(token);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid invoice token',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    getPaymentQr: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { token } = invoiceShareTokenParamSchema.parse(request.params);
        const query = request.query as { format?: string };
        const { png, json } = await service.getPaymentQr(token);

        if (query.format === 'json') {
          return sendData(reply, json);
        }

        return reply
          .header('Content-Type', 'image/png')
          .header('Cache-Control', 'no-store')
          .send(png);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid invoice token',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    createShareLink: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = invoiceIdParamSchema.parse(request.params);
        const data = await service.ensureShareLink(businessId, id, accountId);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    revokeShareLink: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { businessId } = requireAuthContext(request);
        const { id } = invoiceIdParamSchema.parse(request.params);
        const data = await service.revokeShareLink(businessId, id);
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    regenerateShareLink: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = invoiceIdParamSchema.parse(request.params);
        const data = await service.regenerateShareLink(
          businessId,
          id,
          accountId,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    notifySaleInvoice: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id } = invoiceIdParamSchema.parse(request.params);
        const body = sendSaleInvoiceBodySchema.parse(request.body ?? {});
        const data = await service.notifySaleInvoice(
          businessId,
          id,
          accountId,
          body.phone,
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },

    sendPaymentReminder: async (
      request: FastifyRequest,
      reply: FastifyReply,
    ) => {
      try {
        const { accountId, businessId } = requireAuthContext(request);
        const { id: partyId } = partyIdParamSchema.parse(request.params);
        const body = sendPaymentReminderBodySchema.parse(request.body ?? {});
        const data = await service.notifyPaymentReminder(
          businessId,
          accountId,
          {
            partyId,
            salesDocumentId: body.sales_document_id,
            phone: body.phone,
            dueDate: body.due_date,
          },
        );
        return sendData(reply, data);
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
