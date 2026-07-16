import { listPaymentsQuerySchema } from '../../modules/accounting/payment.schema';
import { allocationIdParamSchema } from '../../modules/accounting/payment.schema';
import { listJobWorkOrdersQuerySchema } from '../../modules/job-work/job-work-order.schema';
import { dashboardQuerySchema } from '../../modules/dashboard/dashboard.schema';
import { jobWorkExamples, paymentExamples } from '../examples';
import { crudPaths } from '../operations';
import {
  okPaginatedResponse,
  okResponse,
  pathParamsFromZod,
  queryParamsFromZod,
  ref,
  securedOperation,
  standardErrorResponses,
} from '../helpers';
import { Schema } from '../schema-names';

const paymentIdParam = {
  name: 'id',
  in: 'path' as const,
  required: true,
  schema: { type: 'string', format: 'uuid' },
  description: 'Payment UUID.',
};

export function buildAccountingPaths() {
  const paymentsCrud = crudPaths({
    basePath: '/accounting/payments',
    tag: 'Payments',
    singular: 'Payment',
    plural: 'Payments',
    operationKeys: { list: 'Payments', item: 'Payment' },
    querySchema: listPaymentsQuerySchema,
    querySchemaName: Schema.ListPaymentsQuery,
    createBodyRef: Schema.CreatePaymentRequest,
    updateBodyRef: Schema.UpdatePaymentRequest,
    itemRef: Schema.PaymentResponse,
    createExamples: {
      ...paymentExamples.receivePayment,
      ...paymentExamples.makePayment,
    },
    listDescription:
      'Lists payment receipts and payouts. Filter by party, direction (received/paid), and date range.',
  });

  const allocations = {
    '/accounting/payments/{id}/allocations': {
      get: securedOperation({
        tags: ['Payments'],
        summary: 'List Payment Allocations',
        description:
          'Returns how a payment is allocated across sales and purchase documents.',
        operationId: 'listPaymentAllocations',
        parameters: [paymentIdParam],
        responses: {
          200: okPaginatedResponse(
            'Payment allocations',
            Schema.PaymentAllocationResponse,
          ),
          ...standardErrorResponses,
        },
      }),
      post: securedOperation({
        tags: ['Payments'],
        summary: 'Add Payment Allocation',
        description:
          'Allocates part of a payment to a sales or purchase document. Total allocations cannot exceed the payment amount.',
        operationId: 'addPaymentAllocation',
        parameters: [paymentIdParam],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref(Schema.CreatePaymentAllocationRequest),
            },
          },
        },
        responses: {
          201: okResponse('Allocation added', Schema.PaymentAllocationResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/accounting/payments/{id}/allocations/{allocationId}': {
      delete: securedOperation({
        tags: ['Payments'],
        summary: 'Remove Payment Allocation',
        description: 'Removes an allocation from a payment.',
        operationId: 'deletePaymentAllocation',
        parameters: pathParamsFromZod(
          allocationIdParamSchema,
          Schema.PaymentAllocationParams,
        ),
        responses: {
          204: { description: 'Allocation removed' },
          ...standardErrorResponses,
        },
      }),
    },
  };

  return { ...paymentsCrud, ...allocations };
}

export function buildDashboardPaths() {
  return {
    '/dashboard': {
      get: securedOperation({
        tags: ['Dashboard'],
        summary: 'Get Dashboard',
        description:
          'Returns KPI summary for the active business: sales, purchases, receivables, payables, and stock alerts for the selected period.',
        operationId: 'getDashboard',
        parameters: queryParamsFromZod(
          dashboardQuerySchema,
          Schema.DashboardQuery,
        ),
        responses: {
          200: okResponse('Dashboard summary', Schema.DashboardResponse),
          ...standardErrorResponses,
        },
      }),
    },
  };
}

export function buildJobWorkPaths() {
  return crudPaths({
    basePath: '/job-work/job-work-orders',
    tag: 'Job Work',
    singular: 'Job Work Order',
    plural: 'Job Work Orders',
    operationKeys: { list: 'JobWorkOrders', item: 'JobWorkOrder' },
    querySchema: listJobWorkOrdersQuerySchema,
    querySchemaName: Schema.ListJobWorkOrdersQuery,
    createBodyRef: Schema.CreateJobWorkOrderRequest,
    updateBodyRef: Schema.UpdateJobWorkOrderRequest,
    itemRef: Schema.JobWorkOrderResponse,
    createExamples: jobWorkExamples.createOrder,
    listDescription:
      'Lists manufacturing/job-work orders with raw materials and additional costs.',
  });
}
