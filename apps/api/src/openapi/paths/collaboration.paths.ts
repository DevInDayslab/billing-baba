import {
  dataResponseSchema,
  okResponse,
  ref,
  securedOperation,
  standardErrorResponses,
  unsecuredOperation,
} from '../helpers';
import { Schema } from '../schema-names';

export function buildCollaborationPaths() {
  const tag = 'Collaboration';

  return {
    '/collaboration/invitations': {
      get: securedOperation({
        tags: [tag],
        summary: 'List invitations',
        description:
          'Returns all invitations for the active business. Requires business owner role.',
        operationId: 'listInvitations',
        responses: {
          200: {
            description: 'Invitation list',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'array',
                      items: ref(Schema.InvitationResponse),
                    },
                  },
                },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
      post: securedOperation({
        tags: [tag],
        summary: 'Create invitation',
        description:
          'Invites a user to collaborate on the active business. Requires business owner role. Sends a notification with the invitation URL.',
        operationId: 'createInvitation',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref(Schema.CreateInvitationRequest),
            },
          },
        },
        responses: {
          201: okResponse('Invitation created', Schema.InvitationResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/invitations/reinvite/{id}': {
      post: securedOperation({
        tags: [tag],
        summary: 'Reinvite user',
        description:
          'Cancels a previous invitation and creates a new one with a fresh token. Requires business owner role.',
        operationId: 'reinviteUser',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          201: okResponse('Invitation reissued', Schema.InvitationResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/invitations/{id}/cancel': {
      post: securedOperation({
        tags: [tag],
        summary: 'Cancel invitation',
        description:
          'Cancels a pending or opened invitation. Requires business owner role.',
        operationId: 'cancelInvitation',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
          },
        ],
        responses: {
          200: okResponse('Invitation cancelled', Schema.InvitationResponse),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/invitations/{token}': {
      get: unsecuredOperation({
        tags: [tag],
        summary: 'Get invitation by token',
        description:
          'Returns invitation details for the invite website. On first successful load, transitions status from pending to opened.',
        operationId: 'getInvitationByToken',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
            description: 'Cryptographically random invitation token.',
          },
        ],
        responses: {
          200: okResponse(
            'Invitation details',
            Schema.InvitationPublicResponse,
          ),
          410: {
            description: 'Invitation expired',
            content: {
              'application/json': {
                schema: dataResponseSchema(ref('ErrorResponse')),
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/invitations/{token}/accept': {
      post: unsecuredOperation({
        tags: [tag],
        summary: 'Accept invitation',
        description:
          'Accepts the invitation, creates a company member, and links the invitee account by phone or email.',
        operationId: 'acceptInvitation',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          200: okResponse(
            'Invitation accepted',
            Schema.AcceptInvitationResponse,
          ),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/invitations/{token}/reject': {
      post: unsecuredOperation({
        tags: [tag],
        summary: 'Reject invitation',
        description: 'Rejects a pending or opened invitation.',
        operationId: 'rejectInvitation',
        parameters: [
          {
            name: 'token',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          200: okResponse(
            'Invitation rejected',
            Schema.InvitationPublicResponse,
          ),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/company-members': {
      get: securedOperation({
        tags: [tag],
        summary: 'List company members',
        description:
          'Returns the business owner and all collaborators for the active company. Requires business owner role.',
        operationId: 'listCompanyMembers',
        responses: {
          200: {
            description: 'Company members',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'array',
                      items: ref('CompanyMemberResponse'),
                    },
                  },
                },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/company-members/{id}': {
      patch: securedOperation({
        tags: [tag],
        summary: 'Update member role',
        description:
          'Updates a pending or joined collaborator role. Requires business owner role.',
        operationId: 'updateCompanyMember',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: ref('UpdateCompanyMemberRequest'),
            },
          },
        },
        responses: {
          200: okResponse('Member updated', 'CompanyMemberResponse'),
          ...standardErrorResponses,
        },
      }),
      delete: securedOperation({
        tags: [tag],
        summary: 'Remove company member',
        description:
          'Cancels a pending invitation or removes a joined collaborator. Requires business owner role.',
        operationId: 'removeCompanyMember',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string' },
          },
        ],
        responses: {
          200: okResponse('Member removed', 'SuccessResponse'),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/company-members/{id}/leave': {
      post: securedOperation({
        tags: [tag],
        summary: 'Leave shared company',
        description:
          'Marks the authenticated user as having left a shared company.',
        operationId: 'leaveCompany',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'string', format: 'uuid' },
            description: 'Company member UUID.',
          },
        ],
        responses: {
          200: okResponse('Left company', 'SuccessResponse'),
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/companies/shared': {
      get: securedOperation({
        tags: [tag],
        summary: 'List shared companies',
        description:
          'Returns companies the authenticated user has joined as a collaborator.',
        operationId: 'listSharedCompanies',
        responses: {
          200: {
            description: 'Shared companies',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'array',
                      items: ref(Schema.SharedCompanyResponse),
                    },
                  },
                },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
    '/collaboration/companies/invitations': {
      get: securedOperation({
        tags: [tag],
        summary: 'List pending invitations',
        description:
          'Returns pending and expired invitations for the authenticated user phone/email.',
        operationId: 'listPendingInvitations',
        responses: {
          200: {
            description: 'Pending invitations',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  required: ['data'],
                  properties: {
                    data: {
                      type: 'array',
                      items: ref(Schema.PendingInvitationResponse),
                    },
                  },
                },
              },
            },
          },
          ...standardErrorResponses,
        },
      }),
    },
  };
}
