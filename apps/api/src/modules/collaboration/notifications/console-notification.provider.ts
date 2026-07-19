import type {
  InvitationNotificationPayload,
  NotificationProvider,
} from './notification.service';

export class ConsoleNotificationProvider implements NotificationProvider {
  async sendInvitation(payload: InvitationNotificationPayload): Promise<void> {
    const contact = payload.phone ?? payload.email ?? 'N/A';

    console.log('==============================');
    console.log('WHATSAPP INVITATION');
    console.log(`Company: ${payload.companyName}`);
    console.log(`Role: ${payload.roleLabel}`);
    console.log(`Accept invitation: ${payload.invitationUrl}`);
  }
}
