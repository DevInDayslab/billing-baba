import type { FastifyPluginAsync } from 'fastify';
import {
  decodeStorageKey,
  type LocalFilesystemProvider,
} from '../../providers/storage/local-filesystem-provider';

export function createDevStorageRoutes(
  provider: LocalFilesystemProvider,
): FastifyPluginAsync {
  return async (app) => {
    app.addContentTypeParser(
      '*',
      { parseAs: 'buffer' },
      (_request, body, done) => {
        done(null, body);
      },
    );

    app.put('/objects/*', async (request, reply) => {
      const encodedKey = (request.params as { '*': string })['*'];
      if (!encodedKey) {
        return reply.code(400).send({ error: 'Missing object key' });
      }

      const key = decodeStorageKey(encodedKey);
      const body = request.body;
      if (!Buffer.isBuffer(body)) {
        return reply.code(400).send({ error: 'Expected binary body' });
      }

      const contentType =
        typeof request.headers['content-type'] === 'string'
          ? request.headers['content-type']
          : 'application/octet-stream';

      await provider.putObject({
        key,
        body,
        mimeType: contentType,
      });

      return reply.code(200).send();
    });

    app.get('/objects/*', async (request, reply) => {
      const encodedKey = (request.params as { '*': string })['*'];
      if (!encodedKey) {
        return reply.code(400).send({ error: 'Missing object key' });
      }

      const key = decodeStorageKey(encodedKey);
      const head = await provider.head(key);
      if (!head.exists) {
        return reply.code(404).send({ error: 'Object not found' });
      }

      const object = await provider.getObject(key);
      if (object.contentType) {
        reply.header('Content-Type', object.contentType);
      }
      return reply.send(object.body);
    });
  };
}
