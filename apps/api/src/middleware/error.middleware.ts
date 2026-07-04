import type { FastifyError, FastifyInstance } from 'fastify';
import { AppError } from '../shared/errors';
import type { ApiErrorResponse } from '../shared/types';

function buildErrorResponse(
  requestId: string,
  code: string,
  message: string,
  details: Record<string, string[]> | null = null,
): ApiErrorResponse {
  return {
    error: {
      code,
      message,
      ...(details ? { details } : {}),
    },
    requestId,
  };
}

export function registerErrorHandler(app: FastifyInstance): void {
  app.setNotFoundHandler((request, reply) => {
    reply.header('X-Request-Id', request.id);

    return reply
      .status(404)
      .send(buildErrorResponse(request.id, 'NOT_FOUND', 'Resource not found'));
  });

  app.setErrorHandler((error: FastifyError | AppError, request, reply) => {
    reply.header('X-Request-Id', request.id);

    if (error instanceof AppError) {
      return reply
        .status(error.statusCode)
        .send(
          buildErrorResponse(
            request.id,
            error.code,
            error.message,
            error.errors,
          ),
        );
    }

    request.log.error({ err: error, requestId: request.id });

    const statusCode = error.statusCode ?? 500;
    const message =
      statusCode >= 500 ? 'An unexpected error occurred' : error.message;
    const code = statusCode >= 500 ? 'INTERNAL_SERVER_ERROR' : 'REQUEST_ERROR';

    return reply
      .status(statusCode)
      .send(buildErrorResponse(request.id, code, message));
  });
}
