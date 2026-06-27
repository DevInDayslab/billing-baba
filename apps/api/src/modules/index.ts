import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';
import { accountingModule } from './accounting';
import { authModule } from './auth';
import { businessModule } from './business';
import { crmModule } from './crm';
import { createHealthModule } from './health';
import { inventoryModule } from './inventory';
import { purchasesModule } from './purchases';
import { reportsModule } from './reports';
import { salesModule } from './sales';
import { settingsModule } from './settings';
import { syncModule } from './sync';

export async function registerModules(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await app.register(
    async (api) => {
      await api.register(createHealthModule(config));
      await api.register(authModule, { prefix: '/auth' });
      await api.register(businessModule, { prefix: '/businesses' });
      await api.register(crmModule, { prefix: '/crm' });
      await api.register(inventoryModule, { prefix: '/inventory' });
      await api.register(salesModule, { prefix: '/sales' });
      await api.register(purchasesModule, { prefix: '/purchases' });
      await api.register(accountingModule, { prefix: '/accounting' });
      await api.register(reportsModule, { prefix: '/reports' });
      await api.register(settingsModule, { prefix: '/settings' });
      await api.register(syncModule, { prefix: '/sync' });
    },
    { prefix: config.apiPrefix },
  );
}
