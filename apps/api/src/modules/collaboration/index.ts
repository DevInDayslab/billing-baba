import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { createCompanyDirectoryRoutes } from './routes/company-directory.routes';
import { createCompanyMemberRoutes } from './routes/company-member.routes';
import { createInvitationRoutes } from './routes/invitation.routes';
import { createPermissionsRoutes } from './routes/permissions.routes';

export function createCollaborationModule(
  config: AppConfig,
): FastifyPluginAsync {
  return async (app) => {
    await app.register(createInvitationRoutes(config), {
      prefix: '/invitations',
    });
    await app.register(createCompanyMemberRoutes(), {
      prefix: '/company-members',
    });
    await app.register(createCompanyDirectoryRoutes(config), {
      prefix: '/companies',
    });
    await app.register(createPermissionsRoutes(), {
      prefix: '/permissions',
    });
  };
}
