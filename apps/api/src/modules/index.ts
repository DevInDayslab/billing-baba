import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../config/app_config';
import { createAccountingModule } from './accounting';
import { createAuthModule } from './auth';
import { businessModule, businessProfileModule } from './business';
import { createCollaborationModule } from './collaboration';
import { crmModule } from './crm';
import { dashboardModule } from './dashboard';
import { documentAttachmentsModule } from './document-attachments';
import {
  generatedDocumentsModule,
  publicGeneratedDocumentsModule,
} from './generated-documents';
import { createHealthModule } from './health';
import { hiddenLedgerModule } from './hidden-ledger';
import { inventoryModule } from './inventory';
import {
  createPartyReminderRoutes,
  createPublicInvoiceRoutes,
} from './invoice-share';
import { jobWorkModule } from './job-work';
import { createNotificationsModule } from './notifications/notifications.routes';
import { partiesModule } from './parties';
import { purchasesModule } from './purchases';
import { reportsModule } from './reports';
import { createPaymentGatewayModule } from './payment-gateway';
import { createSalesModule } from './sales';
import { settingsModule } from './settings';
import { createStorageModule } from './storage';
import { createSubscriptionModule } from './subscription';
import { syncModule } from './sync';
import { gstinModule } from './gstin';

export async function registerModules(
  app: FastifyInstance,
  config: AppConfig,
): Promise<void> {
  await app.register(
    async (api) => {
      await api.register(createHealthModule(config));
      await api.register(createAuthModule(config), { prefix: '/auth' });
      await api.register(businessModule(config), { prefix: '/businesses' });
      await api.register(businessProfileModule(config), {
        prefix: '/business',
      });
      await api.register(partiesModule(config), { prefix: '/parties' });
      await api.register(createPartyReminderRoutes(config), {
        prefix: '/parties',
      });
      await api.register(crmModule, { prefix: '/crm' });
      await api.register(inventoryModule(config), { prefix: '/inventory' });
      await api.register(createSalesModule(config), { prefix: '/sales' });
      await api.register(jobWorkModule, { prefix: '/job-work' });
      await api.register(purchasesModule, { prefix: '/purchases' });
      await api.register(createAccountingModule(config), {
        prefix: '/accounting',
      });
      await api.register(hiddenLedgerModule, { prefix: '/hidden-ledger' });
      await api.register(dashboardModule, { prefix: '/dashboard' });
      await api.register(reportsModule, { prefix: '/reports' });
      await api.register(settingsModule, { prefix: '/settings' });
      await api.register(createStorageModule(config), { prefix: '/storage' });
      await api.register(documentAttachmentsModule(config), {
        prefix: '/document-attachments',
      });
      await api.register(generatedDocumentsModule(config), {
        prefix: '/generated-documents',
      });
      await api.register(syncModule, { prefix: '/sync' });
      await api.register(createCollaborationModule(config), {
        prefix: '/collaboration',
      });
      await api.register(createPublicInvoiceRoutes(config), {
        prefix: '/public/invoices',
      });
      await api.register(publicGeneratedDocumentsModule(config), {
        prefix: '/public/generated-documents',
      });
      await api.register(createNotificationsModule(config), {
        prefix: '/notifications',
      });
      await api.register(createSubscriptionModule(config), {
        prefix: '/subscription',
      });
      await api.register(createPaymentGatewayModule(config), {
        prefix: '/payments',
      });
      await api.register(gstinModule(config), { prefix: '/gstin' });
    },
    { prefix: config.apiPrefix },
  );
}
