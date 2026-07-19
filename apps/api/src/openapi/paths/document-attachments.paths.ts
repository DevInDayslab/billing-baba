import {
  okEmptyResponse,
  securedOperation,
  standardErrorResponses,
} from '../helpers';

const tag = 'Document Attachments';

export function buildDocumentAttachmentPaths() {
  return {
    '/document-attachments': {
      get: securedOperation({
        tags: [tag],
        summary: 'List document attachments',
        operationId: 'listDocumentAttachments',
        parameters: [
          {
            name: 'entity_type',
            in: 'query',
            required: true,
            schema: {
              type: 'string',
              enum: [
                'sale',
                'purchase',
                'estimate',
                'sale_order',
                'purchase_order',
                'delivery_challan',
                'payment_in',
                'payment_out',
                'expense',
                'job_work',
              ],
            },
          },
          {
            name: 'entity_id',
            in: 'query',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: {
            description: 'Attachment list',
            content: {
              'application/json': {
                schema: { type: 'object' },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
      post: securedOperation({
        tags: [tag],
        summary: 'Create upload intent or complete attachment upload',
        operationId: 'uploadDocumentAttachment',
        parameters: [
          {
            name: 'entity_type',
            in: 'query',
            required: true,
            schema: { type: 'string' },
          },
          {
            name: 'entity_id',
            in: 'query',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { type: 'object' },
            },
          },
        },
        responses: {
          201: {
            description: 'Upload intent or completed attachment',
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
    '/document-attachments/{id}/url': {
      get: securedOperation({
        tags: [tag],
        summary: 'Get attachment download URL',
        operationId: 'getDocumentAttachmentDownloadUrl',
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
            description: 'Signed download URL',
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
    '/document-attachments/{id}': {
      patch: securedOperation({
        tags: [tag],
        summary: 'Rename attachment',
        operationId: 'updateDocumentAttachment',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: {
                type: 'object',
                required: ['file_name'],
                properties: {
                  file_name: { type: 'string' },
                },
              },
            },
          },
        },
        responses: {
          200: {
            description: 'Updated attachment',
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
        summary: 'Delete attachment',
        operationId: 'deleteDocumentAttachment',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          204: okEmptyResponse('Attachment deleted'),
          ...standardErrorResponses,
        },
      }),
    },
  };
}
