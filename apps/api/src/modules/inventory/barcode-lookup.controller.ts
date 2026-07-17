import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { BarcodeGeminiService } from './barcode-gemini.service';
import { barcodeLookupBodySchema } from './barcode-lookup.schema';
import { formatZodError } from './inventory.controller-helpers';

export function createBarcodeLookupController() {
  return {
    lookup: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const body = barcodeLookupBodySchema.parse(request.body);
        const service = new BarcodeGeminiService();
        const result = await service.lookupBarcode(body.barcode);

        return sendData(reply, { ...result, source: 'gemini' });
      } catch (error) {
        if (error instanceof ZodError) {
          throw new AppError(
            'VALIDATION_ERROR',
            'Invalid request body',
            400,
            formatZodError(error),
          );
        }
        throw error;
      }
    },
  };
}
