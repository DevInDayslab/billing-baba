import type { FastifyInstance } from 'fastify';

declare module 'fastify' {
  interface FastifyRequest {
    startTime?: number;
  }
}

export async function registerRequestLoggingMiddleware(
  app: FastifyInstance,
): Promise<void> {
  app.addHook('onRequest', async (request, reply) => {
    request.startTime = Date.now();
    reply.header('X-Request-Id', request.id);
  });

  app.addHook('onResponse', async (request, reply) => {
    const duration = request.startTime
      ? Date.now() - request.startTime
      : undefined;

    request.log.info({
      requestId: request.id,
      method: request.method,
      path: request.url,
      statusCode: reply.statusCode,
      duration,
      // TODO: userId — populate once authentication is implemented.
      // TODO: businessId — populate once authentication is implemented.
    });
  });
}
