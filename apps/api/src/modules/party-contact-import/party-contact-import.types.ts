export type PartyContactImportStatus =
  | 'pending'
  | 'opened'
  | 'submitted'
  | 'completed'
  | 'expired'
  | 'cancelled';

export type PartyContactImportSessionRow = {
  id: string;
  businessId: string;
  createdByAccountId: string;
  token: string;
  status: PartyContactImportStatus;
  expiresAt: Date;
  openedAt: Date | null;
  submittedAt: Date | null;
  completedAt: Date | null;
  createdAt: Date;
  updatedAt: Date;
};

export type PartyContactImportStagingRow = {
  id: string;
  sessionId: string;
  sortOrder: number;
  displayName: string;
  primaryPhone: string;
  phones: string[];
  email: string | null;
  address: string | null;
};

export type PartyContactImportSessionDto = {
  id: string;
  business_id: string;
  status: PartyContactImportStatus;
  expires_at: string;
  opened_at: string | null;
  submitted_at: string | null;
  completed_at: string | null;
  staging_count: number;
  staging_rows?: PartyContactImportStagingRowDto[];
  company_name?: string;
};

export type PartyContactImportStagingRowDto = {
  display_name: string;
  primary_phone: string;
  phones: string[];
  email: string | null;
  address: string | null;
  sort_order: number;
};

export type CreatePartyContactImportSessionDto = {
  session_id: string;
  token: string;
  web_url: string;
  deep_link_url: string;
  qr_data_url: string;
  expires_at: string;
  notification_sent: boolean;
};

export type PartyContactImportPublicDto = {
  company_name: string;
  status: PartyContactImportStatus;
  expires_at: string;
};
