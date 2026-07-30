import { useMutation, useQuery } from '@tanstack/react-query';
import { apiFetch } from './client';

export type InvitationDetails = {
  id: string;
  status: string;
  company_name: string;
  owner_name: string;
  owner_phone: string;
  role: string;
  expires_at: string;
  invitation_url: string;
};

const ROLE_LABELS: Record<string, string> = {
  secondary_admin: 'Secondary Admin',
  salesman: 'Salesman',
  biller: 'Biller',
  biller_and_salesman: 'Biller and Salesman',
  accountant: 'CA / Accountant',
  accountant_edit_access: 'CA / Accountant (Edit Access)',
  stock_keeper: 'Stock Keeper',
};

export function roleLabel(role: string): string {
  return ROLE_LABELS[role] ?? role;
}

export function useInvitation(token: string | undefined) {
  return useQuery({
    queryKey: ['invitation', token],
    enabled: Boolean(token),
    queryFn: () => apiFetch<InvitationDetails>(`/invitations/${token}`),
    retry: false,
  });
}

export function useAcceptInvitation(token: string | undefined) {
  return useMutation({
    mutationFn: () =>
      apiFetch<{ member_id: string }>(`/invitations/${token}/accept`, {
        method: 'POST',
      }),
  });
}

export function useRejectInvitation(token: string | undefined) {
  return useMutation({
    mutationFn: () =>
      apiFetch<InvitationDetails>(`/invitations/${token}/reject`, {
        method: 'POST',
      }),
  });
}
