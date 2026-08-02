import type { FastifyReply, FastifyRequest } from 'fastify';
import { ZodError } from 'zod';
import type { AppConfig } from '../../config/app_config';
import { AppError } from '../../shared/errors/app-error';
import { sendData } from '../../shared/http/response';
import { verifyGstinBodySchema } from './gstin.dto';
import { GstinService } from './gstin.service';

function formatZodError(error: ZodError): Record<string, string[]> {
  const errors: Record<string, string[]> = {};
  for (const issue of error.issues) {
    const path = issue.path.join('.') || 'body';
    errors[path] = errors[path] ?? [];
    errors[path].push(issue.message);
  }
  return errors;
}

export function createGstinController(config: AppConfig) {
  const service = new GstinService(config);

  return {
    verify: async (request: FastifyRequest, reply: FastifyReply) => {
      try {
        const body = verifyGstinBodySchema.parse(request.body);
        const data = await service.verifyGSTIN(body.gstin, request.log);
        return sendData(reply, data);
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
