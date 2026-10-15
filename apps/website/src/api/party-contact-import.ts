import { useQuery } from '@tanstack/react-query';
import { apiFetch } from './client';

export type PartyContactImportPublic = {
  company_name: string;
  status: string;
  expires_at: string;
};

export function usePartyContactImportPublic(token: string | undefined) {
  return useQuery({
    queryKey: ['party-contact-import', token],
    enabled: Boolean(token),
    queryFn: () =>
      apiFetch<PartyContactImportPublic>(`/${token}`, {
        basePath: '/public/party-contact-import',
      }),
    retry: false,
  });
}
