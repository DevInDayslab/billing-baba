import type {
  PartyContactImportSessionDto,
  PartyContactImportSessionRow,
  PartyContactImportStagingRow,
  PartyContactImportStagingRowDto,
} from './party-contact-import.types';

export function toStagingRowDto(
  row: PartyContactImportStagingRow,
): PartyContactImportStagingRowDto {
  return {
    display_name: row.displayName,
    primary_phone: row.primaryPhone,
    phones: row.phones,
    email: row.email,
    address: row.address,
    sort_order: row.sortOrder,
  };
}

export function toSessionDto(
  session: PartyContactImportSessionRow,
  stagingCount: number,
  options?: {
    stagingRows?: PartyContactImportStagingRow[];
    companyName?: string;
  },
): PartyContactImportSessionDto {
  return {
    id: session.id,
    business_id: session.businessId,
    status: session.status,
    expires_at: session.expiresAt.toISOString(),
    opened_at: session.openedAt?.toISOString() ?? null,
    submitted_at: session.submittedAt?.toISOString() ?? null,
    completed_at: session.completedAt?.toISOString() ?? null,
    staging_count: stagingCount,
    staging_rows: options?.stagingRows?.map(toStagingRowDto),
    company_name: options?.companyName,
  };
}
