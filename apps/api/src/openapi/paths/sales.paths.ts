import {
  listPosSessionsQuerySchema,
  listSalesDocumentsQuerySchema,
  salesLineIdParamSchema,
} from '../../modules/sales/sales-document.schema';
import { salesExamples } from '../examples';
import {
  jsonRequestBody,
  okPaginatedResponse,
  okResponse,
  securedOperation,
  standardErrorResponses,
} from '../helpers';
import {
  documentActionOperation,
  documentCrudPaths,
  getByIdOperation,
  listOperation,
  updateOperation,
} from '../operations';
import { Schema } from '../schema-names';

const idParam = {
  name: 'id',
  in: 'path' as const,
  required: true,
  schema: { type: 'string', format: 'uuid' },
};

export function buildSalesPaths() {
  const documents = documentCrudPaths({
    basePath: '/sales/sales-documents',
    tag: 'Sales',
    singular: 'Sales Document',
    plural: 'Sales Documents',
    operationKeys: { list: 'SalesDocuments', item: 'SalesDocument' },
    querySchema: listSalesDocumentsQuerySchema,
    querySchemaName: Schema.ListSalesDocumentsQuery,
    createBodyRef: Schema.CreateSalesDocumentRequest,
    updateBodyRef: Schema.UpdateSalesDocumentRequest,
    itemRef: Schema.SalesDocumentResponse,
    lineRef: Schema.SalesLineResponse,
    createLineRef: Schema.CreateSalesLineRequest,
    updateLineRef: Schema.UpdateSalesLineRequest,
    lineIdParamSchema: salesLineIdParamSchema,
    lineIdParamSchemaName: Schema.SalesLineIdParams,
    convertBodyRef: Schema.ConvertSalesDocumentRequest,
    finalizeBodyRef: Schema.FinalizeSalesDocumentRequest,
    createExamples: {
      ...salesExamples.createTaxInvoice,
      ...salesExamples.createEstimate,
    },
    convertExamples: salesExamples.convert,
    finalizeExamples: salesExamples.finalize,
    lineExamples: salesExamples.addLine,
    listDescription:
      'Lists sales documents (estimates, invoices, orders, returns). Filter by type, status, party, and date range.',
    extraActions: {
      '/sales/sales-documents/{id}/brand-swap': {
        post: documentActionOperation({
          tag: 'Sales',
          summary: 'Brand Swap',
          description:
            'Replaces all line items with equivalent items from a different brand. Used in multi-brand retail.',
          operationId: 'brandSwapSalesDocument',
          bodyRef: Schema.BrandSwapRequest,
          bodyRequired: true,
          itemRef: Schema.SalesDocumentResponse,
        }),
      },
    },
  });

  const posSessions = {
    '/sales/pos-sessions': {
      get: listOperation({
        tag: 'POS',
        summary: 'List POS Sessions',
        description:
          'Lists point-of-sale register sessions with opening and closing cash totals.',
        operationId: 'listPosSessions',
        querySchema: listPosSessionsQuerySchema,
        querySchemaName: Schema.ListPosSessionsQuery,
        itemRef: Schema.PosSessionResponse,
      }),
      post: securedOperation({
        tags: ['POS'],
        summary: 'Open POS Session',
        description:
          'Starts a new POS register session. Required before creating POS invoices.',
        operationId: 'createPosSession',
        requestBody: jsonRequestBody(Schema.CreatePosSessionRequest),
        responses: {
          201: okResponse('POS session opened', Schema.PosSessionResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/sales/pos-sessions/{id}': {
      get: getByIdOperation({
        tag: 'POS',
        summary: 'Get POS Session',
        description: 'Returns POS session details including cash totals.',
        operationId: 'getPosSession',
        itemRef: Schema.PosSessionResponse,
      }),
      patch: updateOperation({
        tag: 'POS',
        summary: 'Close POS Session',
        description: 'Ends a POS session with closing cash count.',
        operationId: 'closePosSession',
        bodyRef: Schema.UpdatePosSessionRequest,
        itemRef: Schema.PosSessionResponse,
      }),
    },
    '/sales/pos-sessions/{id}/sales-documents': {
      get: securedOperation({
        tags: ['POS'],
        summary: 'List POS Session Documents',
        description:
          'Returns all sales documents created during a POS session.',
        operationId: 'listPosSessionDocuments',
        parameters: [idParam],
        responses: {
          200: okPaginatedResponse(
            'POS documents',
            Schema.SalesDocumentResponse,
          ),
          ...standardErrorResponses,
        },
      }),
    },
  };

  const sequences = {
    '/sales/document-sequences': {
      get: securedOperation({
        tags: ['POS'],
        summary: 'List Document Sequences',
        description:
          'Returns numbering sequences per document type and series (prefix, next number).',
        operationId: 'listDocumentSequences',
        responses: {
          200: okPaginatedResponse(
            'Document sequences',
            Schema.DocumentSequenceResponse,
          ),
          ...standardErrorResponses,
        },
      }),
    },
    '/sales/document-sequences/{id}': {
      patch: securedOperation({
        tags: ['POS'],
        summary: 'Update Document Sequence',
        description:
          'Updates prefix or next number for a document numbering sequence.',
        operationId: 'updateDocumentSequence',
        parameters: [idParam],
        requestBody: jsonRequestBody(Schema.UpdateDocumentSequenceRequest),
        responses: {
          200: okResponse('Sequence updated', Schema.DocumentSequenceResponse),
          ...standardErrorResponses,
        },
      }),
    },
  };

  return { ...documents, ...posSessions, ...sequences };
}
