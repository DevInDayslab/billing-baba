import type { ZodTypeAny } from 'zod';
import type { ResourceOps } from './schema-names';
import { crudOps } from './schema-names';
import {
  createdResponse,
  jsonRequestBody,
  noContentResponse,
  okPaginatedResponse,
  okResponse,
  optionalJsonRequestBody,
  pathParamsFromZod,
  queryParamsFromZod,
  ref,
  securedOperation,
  standardErrorResponses,
  unsecuredOperation,
} from './helpers';

const idParam = {
  name: 'id',
  in: 'path' as const,
  required: true,
  schema: { type: 'string', format: 'uuid' },
  description: 'Resource UUID.',
  example: '550e8400-e29b-41d4-a716-446655440001',
};

export function listOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  querySchema: ZodTypeAny;
  querySchemaName: string;
  itemRef: string;
}) {
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    parameters: queryParamsFromZod(opts.querySchema, opts.querySchemaName),
    responses: {
      200: okPaginatedResponse('Paginated list', opts.itemRef),
      ...standardErrorResponses,
    },
  });
}

export function getByIdOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  itemRef: string;
  paramName?: string;
}) {
  const param = opts.paramName ?? 'id';
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    parameters: [
      param === 'id'
        ? idParam
        : {
            name: param,
            in: 'path' as const,
            required: true,
            schema: { type: 'string', format: 'uuid' },
            description: 'Resource UUID.',
          },
    ],
    responses: {
      200: okResponse('Resource details', opts.itemRef),
      ...standardErrorResponses,
    },
  });
}

export function createOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  bodyRef: string;
  itemRef: string;
  examples?: Record<string, { summary: string; value: unknown }>;
}) {
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    requestBody: jsonRequestBody(opts.bodyRef, opts.examples),
    responses: {
      201: createdResponse('Created successfully', opts.itemRef),
      ...standardErrorResponses,
    },
  });
}

export function updateOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  bodyRef: string;
  itemRef: string;
  paramName?: string;
  examples?: Record<string, { summary: string; value: unknown }>;
}) {
  const param = opts.paramName ?? 'id';
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    parameters: [
      param === 'id'
        ? idParam
        : {
            name: param,
            in: 'path' as const,
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
    ],
    requestBody: jsonRequestBody(opts.bodyRef, opts.examples),
    responses: {
      200: okResponse('Updated successfully', opts.itemRef),
      ...standardErrorResponses,
    },
  });
}

export function deleteOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  paramName?: string;
}) {
  const param = opts.paramName ?? 'id';
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    parameters: [
      param === 'id'
        ? idParam
        : {
            name: param,
            in: 'path' as const,
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
    ],
    responses: {
      204: noContentResponse('Soft-deleted successfully'),
      ...standardErrorResponses,
    },
  });
}

export function crudPaths(opts: {
  basePath: string;
  tag: string;
  singular: string;
  plural: string;
  operationKeys: { list: string; item: string };
  querySchema: ZodTypeAny;
  querySchemaName: string;
  createBodyRef: string;
  updateBodyRef: string;
  itemRef: string;
  createExamples?: Record<string, { summary: string; value: unknown }>;
  listDescription?: string;
  paramName?: string;
  ops?: ResourceOps;
}) {
  const ops =
    opts.ops ??
    crudOps(
      opts.singular,
      opts.plural,
      opts.operationKeys,
      opts.listDescription,
    );
  const idPath =
    opts.paramName && opts.paramName !== 'id'
      ? `${opts.basePath}/{${opts.paramName}}`
      : `${opts.basePath}/{id}`;

  return {
    [opts.basePath]: {
      get: listOperation({
        tag: opts.tag,
        summary: ops.list.summary,
        description: ops.list.description,
        operationId: ops.list.operationId,
        querySchema: opts.querySchema,
        querySchemaName: opts.querySchemaName,
        itemRef: opts.itemRef,
      }),
      post: createOperation({
        tag: opts.tag,
        summary: ops.create.summary,
        description: ops.create.description,
        operationId: ops.create.operationId,
        bodyRef: opts.createBodyRef,
        itemRef: opts.itemRef,
        examples: opts.createExamples,
      }),
    },
    [idPath]: {
      get: getByIdOperation({
        tag: opts.tag,
        summary: ops.get.summary,
        description: ops.get.description,
        operationId: ops.get.operationId,
        itemRef: opts.itemRef,
        paramName: opts.paramName,
      }),
      patch: updateOperation({
        tag: opts.tag,
        summary: ops.update.summary,
        description: ops.update.description,
        operationId: ops.update.operationId,
        bodyRef: opts.updateBodyRef,
        itemRef: opts.itemRef,
        paramName: opts.paramName,
      }),
      delete: deleteOperation({
        tag: opts.tag,
        summary: ops.delete.summary,
        description: ops.delete.description,
        operationId: ops.delete.operationId,
        paramName: opts.paramName,
      }),
    },
  };
}

export function readOnlyListPaths(opts: {
  basePath: string;
  tag: string;
  singular: string;
  plural: string;
  operationKeys: { list: string; item: string };
  querySchema: ZodTypeAny;
  querySchemaName: string;
  itemRef: string;
  description: string;
}) {
  return {
    [opts.basePath]: {
      get: listOperation({
        tag: opts.tag,
        summary: `List ${opts.plural}`,
        description: opts.description,
        operationId: `list${opts.operationKeys.list}`,
        querySchema: opts.querySchema,
        querySchemaName: opts.querySchemaName,
        itemRef: opts.itemRef,
      }),
    },
    [`${opts.basePath}/{id}`]: {
      get: getByIdOperation({
        tag: opts.tag,
        summary: `Get ${opts.singular}`,
        description: `Returns a single ${opts.singular.toLowerCase()} by ID.`,
        operationId: `get${opts.operationKeys.item}`,
        itemRef: opts.itemRef,
      }),
    },
  };
}

export function documentActionOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  bodyRef?: string;
  bodyRequired?: boolean;
  examples?: Record<string, { summary: string; value: unknown }>;
  itemRef?: string;
}) {
  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    parameters: [idParam],
    ...(opts.bodyRef
      ? {
          requestBody: opts.bodyRequired
            ? jsonRequestBody(opts.bodyRef, opts.examples)
            : optionalJsonRequestBody(opts.bodyRef, opts.examples),
        }
      : {}),
    responses: {
      200: okResponse(
        'Action completed',
        opts.itemRef ?? 'SalesDocumentResponse',
      ),
      ...standardErrorResponses,
    },
  });
}

export function documentLinePaths(opts: {
  basePath: string;
  tag: string;
  documentLabel: string;
  lineRef: string;
  createLineRef: string;
  updateLineRef: string;
  lineIdParamSchema: ZodTypeAny;
  lineIdParamSchemaName: string;
  createExamples?: Record<string, { summary: string; value: unknown }>;
}) {
  const linesPath = `${opts.basePath}/{id}/lines`;
  const linePath = `${opts.basePath}/{id}/lines/{lineId}`;
  const prefix = opts.documentLabel.replace(/\s/g, '');

  return {
    [linesPath]: {
      get: securedOperation({
        tags: [opts.tag],
        summary: `List ${opts.documentLabel} Lines`,
        description: `Returns all line items for a ${opts.documentLabel.toLowerCase()}.`,
        operationId: `list${prefix}Lines`,
        parameters: [idParam],
        responses: {
          200: okPaginatedResponse('Document lines', opts.lineRef),
          ...standardErrorResponses,
        },
      }),
      post: securedOperation({
        tags: [opts.tag],
        summary: `Add ${opts.documentLabel} Line`,
        description: `Adds a line item to a draft ${opts.documentLabel.toLowerCase()}.`,
        operationId: `add${prefix}Line`,
        parameters: [idParam],
        requestBody: jsonRequestBody(opts.createLineRef, opts.createExamples),
        responses: {
          201: createdResponse('Line added', opts.lineRef),
          ...standardErrorResponses,
        },
      }),
    },
    [linePath]: {
      patch: securedOperation({
        tags: [opts.tag],
        summary: `Update ${opts.documentLabel} Line`,
        description: `Updates a line on a draft ${opts.documentLabel.toLowerCase()}.`,
        operationId: `update${prefix}Line`,
        parameters: pathParamsFromZod(
          opts.lineIdParamSchema,
          opts.lineIdParamSchemaName,
        ),
        requestBody: jsonRequestBody(opts.updateLineRef),
        responses: {
          200: okResponse('Line updated', opts.lineRef),
          ...standardErrorResponses,
        },
      }),
      delete: securedOperation({
        tags: [opts.tag],
        summary: `Delete ${opts.documentLabel} Line`,
        description: `Removes a line from a draft ${opts.documentLabel.toLowerCase()}.`,
        operationId: `delete${prefix}Line`,
        parameters: pathParamsFromZod(
          opts.lineIdParamSchema,
          opts.lineIdParamSchemaName,
        ),
        responses: {
          204: noContentResponse('Line deleted'),
          ...standardErrorResponses,
        },
      }),
    },
  };
}

export function documentCrudPaths(opts: {
  basePath: string;
  tag: string;
  singular: string;
  plural: string;
  operationKeys: { list: string; item: string };
  querySchema: ZodTypeAny;
  querySchemaName: string;
  createBodyRef: string;
  updateBodyRef: string;
  itemRef: string;
  lineRef: string;
  createLineRef: string;
  updateLineRef: string;
  lineIdParamSchema: ZodTypeAny;
  lineIdParamSchemaName: string;
  convertBodyRef: string;
  finalizeBodyRef: string;
  createExamples?: Record<string, { summary: string; value: unknown }>;
  convertExamples?: Record<string, { summary: string; value: unknown }>;
  finalizeExamples?: Record<string, { summary: string; value: unknown }>;
  lineExamples?: Record<string, { summary: string; value: unknown }>;
  listDescription?: string;
  extraActions?: Record<string, Record<string, unknown>>;
}) {
  const ops = crudOps(
    opts.singular,
    opts.plural,
    opts.operationKeys,
    opts.listDescription,
  );

  const crud = crudPaths({
    basePath: opts.basePath,
    tag: opts.tag,
    singular: opts.singular,
    plural: opts.plural,
    operationKeys: opts.operationKeys,
    querySchema: opts.querySchema,
    querySchemaName: opts.querySchemaName,
    createBodyRef: opts.createBodyRef,
    updateBodyRef: opts.updateBodyRef,
    itemRef: opts.itemRef,
    createExamples: opts.createExamples,
    listDescription: opts.listDescription,
    ops,
  });

  const lines = documentLinePaths({
    basePath: opts.basePath,
    tag: opts.tag,
    documentLabel: opts.singular,
    lineRef: opts.lineRef,
    createLineRef: opts.createLineRef,
    updateLineRef: opts.updateLineRef,
    lineIdParamSchema: opts.lineIdParamSchema,
    lineIdParamSchemaName: opts.lineIdParamSchemaName,
    createExamples: opts.lineExamples,
  });

  const key = opts.operationKeys.item;

  const actions = {
    [`${opts.basePath}/{id}/finalize`]: {
      post: documentActionOperation({
        tag: opts.tag,
        summary: `Finalize ${opts.singular}`,
        description:
          'Finalizes a draft document — assigns document number and posts stock/accounting entries. Optional godown for stock deduction.',
        operationId: `finalize${key}`,
        bodyRef: opts.finalizeBodyRef,
        bodyRequired: false,
        examples: opts.finalizeExamples,
        itemRef: opts.itemRef,
      }),
    },
    [`${opts.basePath}/{id}/cancel`]: {
      post: documentActionOperation({
        tag: opts.tag,
        summary: `Cancel ${opts.singular}`,
        description:
          'Cancels a finalized document and reverses stock and accounting impact.',
        operationId: `cancel${key}`,
        itemRef: opts.itemRef,
      }),
    },
    [`${opts.basePath}/{id}/convert`]: {
      post: documentActionOperation({
        tag: opts.tag,
        summary: `Convert ${opts.singular}`,
        description:
          'Converts the document to another type (e.g. estimate → tax invoice, purchase order → purchase bill).',
        operationId: `convert${key}`,
        bodyRef: opts.convertBodyRef,
        bodyRequired: true,
        examples: opts.convertExamples,
        itemRef: opts.itemRef,
      }),
    },
    ...(opts.extraActions ?? {}),
  };

  return { ...crud, ...lines, ...actions };
}

export function reportGetOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  querySchema: ZodTypeAny;
  querySchemaName: string;
  paginated?: boolean;
}) {
  const reportNote = [
    opts.description,
    '',
    '**Filters:** Use `period` presets (`today`, `this_month`, etc.) or `from`/`to` for custom ranges. Additional filters vary by report.',
    '**Pagination:** `page` and `limit` apply to paginated reports.',
    '**Export:** Set `format=csv` to download as CSV; default is JSON.',
  ].join('\n');

  return securedOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: reportNote,
    operationId: opts.operationId,
    parameters: queryParamsFromZod(opts.querySchema, opts.querySchemaName),
    responses: {
      200: opts.paginated
        ? {
            description: 'Report data (paginated) or CSV file when format=csv',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    data: ref('ReportPaginatedResponse'),
                    meta: {
                      type: 'object',
                      properties: {
                        page: { type: 'integer', example: 1 },
                        limit: { type: 'integer', example: 20 },
                        total: { type: 'integer', example: 100 },
                        totalPages: { type: 'integer', example: 5 },
                      },
                    },
                  },
                },
              },
              'text/csv': { schema: { type: 'string', format: 'binary' } },
            },
          }
        : {
            description: 'Report data',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: { data: ref('ReportDataResponse') },
                },
              },
            },
          },
      ...standardErrorResponses,
    },
  });
}

export function publicPostOperation(opts: {
  tag: string;
  summary: string;
  description: string;
  operationId: string;
  bodyRef: string;
  responseRef: string;
  examples?: Record<string, { summary: string; value: unknown }>;
  responseExample?: unknown;
}) {
  return unsecuredOperation({
    tags: [opts.tag],
    summary: opts.summary,
    description: opts.description,
    operationId: opts.operationId,
    requestBody: jsonRequestBody(opts.bodyRef, opts.examples),
    responses: {
      200: okResponse('Success', opts.responseRef, opts.responseExample),
      400: standardErrorResponses[400],
      401: standardErrorResponses[401],
      500: standardErrorResponses[500],
    },
  });
}
