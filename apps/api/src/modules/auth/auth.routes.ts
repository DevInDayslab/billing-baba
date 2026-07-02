import type { FastifyPluginAsync } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { authenticate } from '../../middleware/auth.middleware';
import { createAuthController } from './auth.controller';

export function createAuthRoutes(config: AppConfig): FastifyPluginAsync {
  const controller = createAuthController(config);

  return async (app) => {
    app.post('/login', controller.login);
    app.post('/refresh', controller.refresh);
    app.post('/logout', { preHandler: authenticate }, controller.logout);
    app.get('/me', { preHandler: authenticate }, controller.me);

    if (config.enableDevLogin) {
      app.post('/dev-login', controller.devLogin);
    }
  };
}
