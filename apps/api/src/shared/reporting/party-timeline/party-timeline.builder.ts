import type { Database } from '../../../db/client';
import type { PartyLedgerFilter } from '../party-ledger';
import { getTimelineSources } from './party-timeline.registry';
import type {
  PartyKind,
  PartyTimelineContext,
  PartyTimelineRow,
} from './party-timeline.types';
import {
  applyTimelineDateFilter,
  applyTimelineFilter,
  partyKindMatches,
  resolvePartyKind,
} from './party-timeline.utils';

export async function buildPartyTimeline(
  db: Database,
  businessId: string,
  partyId: string,
  partyType: string,
  options: {
    filter?: PartyLedgerFilter;
    from?: string;
    to?: string;
  } = {},
): Promise<PartyTimelineRow[]> {
  const partyKind = resolvePartyKind(partyType);
  const ctx: PartyTimelineContext = {
    db,
    businessId,
    partyId,
    partyKind,
    filter: options.filter,
    from: options.from,
    to: options.to,
  };

  const sourceRows = await Promise.all(
    getTimelineSources()
      .filter((source) => partyKindMatches(partyKind, source.partyKinds))
      .map(async (source) => {
        try {
          return await source.fetch(ctx);
        } catch {
          return [];
        }
      }),
  );

  let rows = sourceRows.flat();
  rows = applyTimelineFilter(rows, options.filter);
  rows = applyTimelineDateFilter(rows, options.from, options.to);

  rows.sort(
    (a, b) =>
      b.createdAt.getTime() - a.createdAt.getTime() ||
      b.documentDate.getTime() - a.documentDate.getTime(),
  );

  return rows;
}

export type { PartyKind, PartyTimelineRow };
