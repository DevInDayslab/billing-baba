import {
  okEmptyResponse,
  securedOperation,
  standardErrorResponses,
} from '../helpers';

const tag = 'Storage';

export function buildStoragePaths() {
  return {
    '/storage/uploads': {
      post: securedOperation({
        tags: [tag],
        summary: 'Create upload intent',
        description:
          'Creates a pending media_assets row and returns a presigned PUT URL. The client uploads bytes directly to object storage.',
        operationId: 'createStorageUploadIntent',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['purpose', 'mime_type', 'file_size'],
                properties: {
                  purpose: {
                    type: 'string',
                    enum: [
                      'branding',
                      'items',
                      'parties',
                      'sales',
                      'purchases',
                      'expenses',
                      'reports',
                      'backups',
                      'documents',
                      'payments',
                      'job_work',
                      'other',
                    ],
                  },
                  visibility: {
                    type: 'string',
                    enum: ['private', 'authenticated', 'public'],
                    default: 'private',
                  },
                  mime_type: { type: 'string', example: 'image/png' },
                  file_size: { type: 'integer', example: 1024 },
                  owner_type: { type: 'string', nullable: true },
                  owner_id: { type: 'string', format: 'uuid', nullable: true },
                  checksum: { type: 'string', nullable: true },
                },
              },
            },
          },
        },
        responses: {
          201: {
            description: 'Upload intent with presigned URL',
            content: {
              'application/json': {
                schema: { type: 'object' },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/storage/uploads/complete': {
      post: securedOperation({
        tags: [tag],
        summary: 'Complete upload',
        description:
          'Verifies the object exists via HEAD and marks the media asset ready.',
        operationId: 'completeStorageUpload',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['intent_id'],
                properties: {
                  intent_id: { type: 'string', format: 'uuid' },
                },
              },
            },
          },
        },
        responses: {
          200: {
            description: 'Ready media asset metadata',
            content: {
              'application/json': {
                schema: { type: 'object' },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/storage/files/{id}': {
      get: securedOperation({
        tags: [tag],
        summary: 'Get media asset metadata',
        operationId: 'getStorageFile',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: {
            description: 'Media asset',
            content: {
              'application/json': {
                schema: { type: 'object' },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
      delete: securedOperation({
        tags: [tag],
        summary: 'Delete media asset',
        description: 'Soft-deletes the registry row and removes the object.',
        operationId: 'deleteStorageFile',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: okEmptyResponse('Deleted'),
          ...standardErrorResponses,
        },
      }),
    },
    '/storage/files/{id}/url': {
      get: securedOperation({
        tags: [tag],
        summary: 'Get download URL',
        description:
          'Returns a signed GET URL for private/authenticated assets, or a public URL for public assets.',
        operationId: 'getStorageFileUrl',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: {
            description: 'Download URL payload',
            content: {
              'application/json': {
                schema: { type: 'object' },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
  };
}
