import type { FastifyRequest } from 'fastify';

export type UserRole = 'owner' | 'manager' | 'staff';

export type JwtAccessPayload = {
  account_id: string;
  phone: string;
  user_id?: string;
  business_id?: string;
  role?: UserRole;
};

export type AccountRecord = {
  id: string;
  phone: string;
  name: string | null;
  email: string | null;
  avatarUrl: string | null;
  timezone: string;
  language: string;
  createdAt: Date;
  updatedAt: Date;
};

export type AccountProfileResponse = {
  display_name: string | null;
  phone: string;
  email: string | null;
  avatar_url: string | null;
  timezone: string;
  language: string;
};

export type BusinessMembership = {
  userId: string;
  businessId: string;
  businessName: string;
  role: UserRole;
  gstin: string | null;
};

export type AuthUserResponse = {
  id: string;
  phone: string;
  name: string | null;
  role?: UserRole;
};

export type BusinessSummaryResponse = {
  id: string;
  name: string;
  role: UserRole;
  gstin: string | null;
};

export type AuthSessionResponse = {
  access_token: string;
  refresh_token: string;
  expires_in: number;
  user: AuthUserResponse;
  businesses: BusinessSummaryResponse[];
};

export type MeResponse = {
  user: AuthUserResponse;
  businesses: BusinessSummaryResponse[];
  selected_business: BusinessSummaryResponse | null;
  profile: AccountProfileResponse;
};

export type Msg91VerifyResponse = {
  type: 'success' | 'error';
  message?: string;
  mobile?: string;
  phone?: string;
  identifier?: string;
  [key: string]: unknown;
};

declare module 'fastify' {
  interface FastifyRequest {
    accountId?: string;
    userId?: string;
    businessId?: string;
    role?: UserRole;
    phone?: string;
  }
}

export type AuthenticatedRequest = FastifyRequest & {
  accountId: string;
  phone: string;
  userId?: string;
  businessId?: string;
  role?: UserRole;
};
