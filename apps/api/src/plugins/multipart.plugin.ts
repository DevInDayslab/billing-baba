import multipart from '@fastify/multipart';
import type { FastifyInstance } from 'fastify';

const MAX_FILE_SIZE_BYTES = 5 * 1024 * 1024;

export async function registerMultipartPlugin(
  app: FastifyInstance,
): Promise<void> {
  await app.register(multipart, {
    limits: {
      fileSize: MAX_FILE_SIZE_BYTES,
      files: 1,
    },
  });
}
