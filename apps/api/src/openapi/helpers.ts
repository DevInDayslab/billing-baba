import type { ZodTypeAny } from 'zod';
import { zodToJsonSchema } from 'zod-to-json-schema';

export function zodSchema(
  schema: ZodTypeAny,
  name?: string,
): Record<string, unknown> {
  return zodToJsonSchema(schema as never, {
    name,
    $refStrategy: 'none',
    target: 'openApi3',
  }) as Record<string, unknown>;
}

export function ref(name: string): { $ref: string } {
  return { $ref: `#/components/schemas/${name}` };
}

export const bearerAuth = {
  bearerAuth: {
    type: 'http' as const,
    scheme: 'bearer',
    bearerFormat: 'JWT',
    description:
      'JWT access token from POST /auth/login or POST /auth/dev-login (development only).',
  },
};

export const businessHeaderNote =
  'Requires a valid JWT whose payload includes `business_id` for the selected business.';

export const paginationQueryProperties = {
  page: {
    type: 'integer',
    minimum: 1,
    default: 1,
    description: 'Page number (1-based).',
  },
  limit: {
    type: 'integer',
    minimum: 1,
    maximum: 100,
    default: 20,
    description: 'Items per page.',
  },
};

export const paginationMetaSchema = {
  type: 'object',
  required: ['page', 'limit', 'total', 'totalPages'],
  properties: {
    page: { type: 'integer', example: 1 },
    limit: { type: 'integer', example: 20 },
    total: { type: 'integer', example: 100 },
    totalPages: { type: 'integer', example: 5 },
  },
};

export const errorResponseSchema = {
  type: 'object',
  required: ['error', 'requestId'],
  properties: {
    error: {
      type: 'object',
      required: ['code', 'message'],
      properties: {
        code: { type: 'string', example: 'VALIDATION_ERROR' },
        message: { type: 'string', example: 'Invalid request body' },
        details: {
          type: 'object',
          additionalProperties: {
            type: 'array',
            items: { type: 'string' },
          },
          example: { name: ['Name is required'] },
        },
      },
    },
    requestId: { type: 'string', example: 'req-abc123' },
  },
};

export function paginatedResponseSchema(itemRef: { $ref: string }) {
  return {
    type: 'object',
    required: ['data', 'meta'],
    properties: {
      data: {
        type: 'array',
        items: itemRef,
      },
      meta: paginationMetaSchema,
    },
  };
}

export function dataResponseSchema(itemRef: { $ref: string }) {
  return {
    type: 'object',
    required: ['data'],
    properties: {
      data: itemRef,
    },
  };
}

export const standardErrorResponses = {
  400: {
    description: 'Validation error',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
  401: {
    description: 'Unauthorized — missing or invalid token',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
  403: {
    description: 'Forbidden — no access to this business',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
  404: {
    description: 'Resource not found',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
  409: {
    description: 'Conflict',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
  422: {
    description: 'Business rule violation',
    content: {
      'application/json': { schema: errorResponseSchema },
    },
  },
};

export function securedOperation(
  operation: Record<string, unknown>,
): Record<string, unknown> {
  return {
    security: [{ bearerAuth: [] }],
    ...operation,
  };
}
