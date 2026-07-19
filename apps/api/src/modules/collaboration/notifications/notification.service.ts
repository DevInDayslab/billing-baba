export type InvitationNotificationPayload = {
  companyName: string;
  roleLabel: string;
  phone: string | null;
  email: string | null;
  invitationUrl: string;
};

export interface NotificationProvider {
  sendInvitation(payload: InvitationNotificationPayload): Promise<void>;
}

export class NotificationService {
  constructor(private readonly provider: NotificationProvider) {}

  async notifyInvitationCreated(
    payload: InvitationNotificationPayload,
  ): Promise<void> {
    await this.provider.sendInvitation(payload);
  }
}
