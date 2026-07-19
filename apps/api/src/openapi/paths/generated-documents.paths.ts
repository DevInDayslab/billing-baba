import {
  okEmptyResponse,
  securedOperation,
  standardErrorResponses,
} from '../helpers';

const tag = 'Generated Documents';

export function buildGeneratedDocumentPaths() {
  return {
    '/generated-documents/lookup': {
      get: securedOperation({
        tags: [tag],
        summary: 'Lookup cached generated document',
        operationId: 'lookupGeneratedDocument',
        parameters: [
          {
            name: 'document_kind',
            in: 'query',
            required: true,
            schema: {
              type: 'string',
              enum: [
                'invoice_pdf',
                'estimate_pdf',
                'receipt_pdf',
                'delivery_challan_pdf',
                'purchase_pdf',
                'report_pdf',
                'excel',
                'csv',
              ],
            },
          },
          {
            name: 'source_type',
            in: 'query',
            required: true,
            schema: {
              type: 'string',
              enum: [
                'sale_document',
                'purchase_document',
                'payment',
                'report',
              ],
            },
          },
          {
            name: 'source_id',
            in: 'query',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: {
            description: 'Cached document metadata or null',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/generated-documents/ensure': {
      post: securedOperation({
        tags: [tag],
        summary: 'Store generated document with version-based cache',
        operationId: 'ensureGeneratedDocument',
        requestBody: {
          required: true,
          content: {
            'application/json': { schema: { type: 'object' } },
          },
        },
        responses: {
          200: {
            description: 'Existing cached document reused',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          201: {
            description: 'New document stored',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/generated-documents/{id}/url': {
      get: securedOperation({
        tags: [tag],
        summary: 'Get signed download URL',
        operationId: 'getGeneratedDocumentSignedUrl',
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
            description: 'Signed URL',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/generated-documents/{id}/regenerate': {
      post: securedOperation({
        tags: [tag],
        summary: 'Force regenerate and replace stored file',
        operationId: 'regenerateGeneratedDocument',
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
            'application/json': { schema: { type: 'object' } },
          },
        },
        responses: {
          200: {
            description: 'Regenerated document',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/public/generated-documents/{token}': {
      get: {
        tags: [tag],
        summary: 'Public generated document metadata',
        operationId: 'getPublicGeneratedDocument',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          200: {
            description: 'Public document metadata with download URL',
            content: {
              'application/json': { schema: { type: 'object' } },
            },
          },
          ...standardErrorResponses,
        },
      },
    },
    '/public/generated-documents/{token}/file': {
      get: {
        tags: [tag],
        summary: 'Redirect to public PDF/file download',
        operationId: 'getPublicGeneratedDocumentFile',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          302: { description: 'Redirect to signed object URL' },
          ...standardErrorResponses,
        },
      },
    },
  };
}
