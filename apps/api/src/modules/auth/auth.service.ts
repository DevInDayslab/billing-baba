import { createHash, randomBytes } from 'node:crypto';
import type { FastifyInstance } from 'fastify';
import type { AppConfig } from '../../config/app_config';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { AccountAvatarService } from '../business/business-branding.service';
import { AuthRepository } from './auth.repository';
import type {
  AccountProfileResponse,
  AccountRecord,
  AuthSessionResponse,
  AuthUserResponse,
  BusinessSummaryResponse,
  JwtAccessPayload,
  MeResponse,
} from './auth.types';
import {
  phoneLookupVariants,
  verifyMsg91WidgetAccessToken,
} from './msg91-widget.service';

const ACCESS_TOKEN_TTL_SECONDS = 15 * 60;
const REFRESH_TOKEN_TTL_MS = 30 * 24 * 60 * 60 * 1000;
const DEVICE_TRUST_TTL_MS = 30 * 24 * 60 * 60 * 1000;

import { ensureDemoCatalogIfEmpty } from '../../db/seed/demo-seeder';
import {
  DEV_ACCOUNT_NAME,
  DEV_BUSINESS_NAME,
  DEV_BUSINESS_PHONE,
  DEV_LOGIN_PHONE,
} from '../../shared/dev-demo.constants';

function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

function generateRefreshToken(): string {
  return randomBytes(32).toString('base64url');
}

function toBusinessSummaries(
  memberships: Awaited<
    ReturnType<AuthRepository['findMembershipsByAccountId']>
  >,
): BusinessSummaryResponse[] {
  return memberships.map((membership) => ({
    id: membership.businessId,
    name: membership.businessName,
    role: membership.role,
    gstin: membership.gstin,
  }));
}

function buildUserResponse(
  account: { id: string; phone: string; name: string | null },
  membership?: { userId: string; role: AuthUserResponse['role'] },
): AuthUserResponse {
  return {
    id: membership?.userId ?? account.id,
    phone: account.phone,
    name: account.name,
    role: membership?.role,
  };
}

function buildProfileResponse(account: AccountRecord): AccountProfileResponse {
  return {
    display_name: account.name,
    phone: account.phone,
    email: account.email,
    avatar_url: account.avatarUrl,
    timezone: account.timezone,
    language: account.language,
  };
}

export class AuthService {
  private readonly repository: AuthRepository;

  constructor(
    private readonly app: FastifyInstance,
    private readonly config: AppConfig,
  ) {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new AuthRepository(db);
  }

  private ensureJwtSecrets(): void {
    if (!this.config.jwtSecret || !this.config.jwtRefreshSecret) {
      throw new AppError(
        'AUTH_NOT_CONFIGURED',
        'JWT secrets are not configured',
        503,
      );
    }
  }

  private ensureAuthSecrets(): void {
    this.ensureJwtSecrets();
    if (!this.config.msg91AuthKey) {
      throw new AppError(
        'AUTH_NOT_CONFIGURED',
        'MSG91 auth key is not configured',
        503,
      );
    }
  }

  private async verifyMsg91AccessToken(
    accessToken: string,
    phoneHint?: string,
  ): Promise<string> {
    this.ensureAuthSecrets();
    const authKey = this.config.msg91AuthKey;
    if (!authKey) {
      throw new AppError(
        'AUTH_NOT_CONFIGURED',
        'MSG91 auth key is not configured',
        503,
      );
    }
    return verifyMsg91WidgetAccessToken(accessToken, authKey, phoneHint);
  }

  private async findOrCreateAccountByPhone(phone: string) {
    const variants = phoneLookupVariants(phone);
    for (const variant of variants) {
      const account = await this.repository.findAccountByPhone(variant);
      if (account) {
        return account;
      }
    }
    return this.repository.createAccount(phone);
  }

  private signAccessToken(payload: JwtAccessPayload): string {
    return this.app.jwt.sign(payload, {
      expiresIn: ACCESS_TOKEN_TTL_SECONDS,
    });
  }

  private normalizePhoneForTrust(phone: string): string {
    const digits = phone.replace(/\D/g, '');
    if (digits.length === 12 && digits.startsWith('91')) {
      return digits.slice(2);
    }
    return digits;
  }

  private phonesMatchForTrust(
    accountPhone: string,
    inputPhone: string,
  ): boolean {
    const normalizedAccount = this.normalizePhoneForTrust(accountPhone);
    const normalizedInput = this.normalizePhoneForTrust(inputPhone);
    if (normalizedAccount === normalizedInput) {
      return true;
    }
    const variants = phoneLookupVariants(inputPhone);
    return (
      variants.includes(accountPhone) || variants.includes(normalizedAccount)
    );
  }

  private async issueDeviceTrust(
    account: { id: string; phone: string },
    deviceId: string,
  ): Promise<{ device_trust_token: string; device_trust_expires_at: string }> {
    const trustToken = generateRefreshToken();
    const trustTokenHash = hashToken(trustToken);
    const expiresAt = new Date(Date.now() + DEVICE_TRUST_TTL_MS);

    await this.repository.revokeDeviceTrustForDevice(account.id, deviceId);
    await this.repository.createDeviceTrustToken({
      accountId: account.id,
      phone: this.normalizePhoneForTrust(account.phone),
      deviceId,
      tokenHash: trustTokenHash,
      expiresAt,
    });

    return {
      device_trust_token: trustToken,
      device_trust_expires_at: expiresAt.toISOString(),
    };
  }

  private async issueSession(
    account: { id: string; phone: string; name: string | null },
    memberships: Awaited<
      ReturnType<AuthRepository['findMembershipsByAccountId']>
    >,
    deviceTrust?: {
      device_trust_token: string;
      device_trust_expires_at: string;
    },
  ): Promise<AuthSessionResponse> {
    const businesses = toBusinessSummaries(memberships);
    const refreshToken = generateRefreshToken();
    const refreshTokenHash = hashToken(refreshToken);
    const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

    let accessPayload: JwtAccessPayload = {
      account_id: account.id,
      phone: account.phone,
    };
    let refreshUserId: string | undefined;
    let userResponse = buildUserResponse(account);

    if (memberships.length === 1) {
      const [membership] = memberships;
      if (!membership) {
        throw new AppError(
          'INTERNAL_ERROR',
          'Unexpected membership state',
          500,
        );
      }
      accessPayload = {
        account_id: account.id,
        phone: account.phone,
        user_id: membership.userId,
        business_id: membership.businessId,
        role: membership.role,
      };
      refreshUserId = membership.userId;
      userResponse = buildUserResponse(account, {
        userId: membership.userId,
        role: membership.role,
      });
    }

    await this.repository.createRefreshToken({
      accountId: account.id,
      userId: refreshUserId,
      tokenHash: refreshTokenHash,
      expiresAt,
    });

    return {
      access_token: this.signAccessToken(accessPayload),
      refresh_token: refreshToken,
      expires_in: ACCESS_TOKEN_TTL_SECONDS,
      user: userResponse,
      businesses,
      ...(deviceTrust ?? {}),
    };
  }

  async login(
    accessToken: string,
    options?: {
      phoneHint?: string;
      rememberFor30Days?: boolean;
      deviceId?: string;
    },
  ): Promise<AuthSessionResponse> {
    const phoneHint = options?.phoneHint;
    const rememberFor30Days = options?.rememberFor30Days ?? false;
    const deviceId = options?.deviceId;
    if (this.config.environment === 'development') {
      const maskedHint = phoneHint
        ? `***${phoneHint.slice(-4)}`
        : '(not provided)';
      this.app.log.info(
        { phoneHint: maskedHint },
        'MSG91 login: verifying access token',
      );
    }

    const phone = await this.verifyMsg91AccessToken(accessToken, phoneHint);

    if (this.config.environment === 'development') {
      this.app.log.info(
        { phone: `***${phone.slice(-4)}` },
        'MSG91 login: token verified, issuing session',
      );
    }

    const account = await this.findOrCreateAccountByPhone(phone);
    await this.repository.ensureAccountProfile(account.id, account.phone);

    const memberships = await this.repository.findMembershipsByAccountId(
      account.id,
    );

    if (rememberFor30Days && deviceId) {
      const deviceTrust = await this.issueDeviceTrust(account, deviceId);
      return this.issueSession(account, memberships, deviceTrust);
    }

    if (deviceId) {
      await this.repository.revokeDeviceTrustForDevice(account.id, deviceId);
    }

    return this.issueSession(account, memberships);
  }

  async loginWithDeviceTrust(input: {
    phone: string;
    deviceId: string;
    deviceTrustToken: string;
  }): Promise<AuthSessionResponse> {
    this.ensureJwtSecrets();

    const tokenHash = hashToken(input.deviceTrustToken);
    const stored = await this.repository.findValidDeviceTrustToken({
      tokenHash,
      deviceId: input.deviceId,
    });

    if (!stored) {
      throw new AppError(
        'INVALID_TOKEN',
        'Invalid or expired device trust token',
        401,
      );
    }

    const accountRow = await this.repository.findAccountById(stored.accountId);
    if (!accountRow) {
      throw new AppError('INVALID_TOKEN', 'Account not found', 401);
    }

    if (!this.phonesMatchForTrust(accountRow.phone, input.phone)) {
      throw new AppError(
        'INVALID_TOKEN',
        'Phone number does not match trusted device',
        401,
      );
    }

    const memberships = await this.repository.findMembershipsByAccountId(
      accountRow.id,
    );

    return this.issueSession(accountRow, memberships);
  }

  async devLogin(): Promise<AuthSessionResponse> {
    this.ensureJwtSecrets();

    let account = await this.repository.findAccountByPhone(DEV_LOGIN_PHONE);
    if (!account) {
      account = await this.repository.createAccount(
        DEV_LOGIN_PHONE,
        DEV_ACCOUNT_NAME,
      );
    } else if (account.name !== DEV_ACCOUNT_NAME) {
      account = await this.repository.updateAccountName(
        account.id,
        DEV_ACCOUNT_NAME,
      );
    }

    let memberships = await this.repository.findMembershipsByAccountId(
      account.id,
    );

    if (memberships.length === 0) {
      const membership = await this.repository.createBusinessWithOwner({
        accountId: account.id,
        businessName: DEV_BUSINESS_NAME,
        ownerName: DEV_ACCOUNT_NAME,
        phone: DEV_BUSINESS_PHONE,
      });
      memberships = [membership];
    } else if (memberships.length > 1) {
      // Dev accounts accumulate many test businesses; seeding all of them on
      // every login is O(n) remote round-trips and blows past Bun's hook timeout.
      const preferred = memberships.find(
        (membership) => membership.businessName === DEV_BUSINESS_NAME,
      );
      if (preferred) {
        memberships = [preferred];
      }
    }

    for (const membership of memberships) {
      await this.repository.ensureInventorySeeds(membership.businessId);
      const db = getDb();
      if (db) {
        await ensureDemoCatalogIfEmpty(db, {
          businessId: membership.businessId,
          accountId: account.id,
          userId: membership.userId,
        });
      }
    }

    if (this.config.environment === 'development') {
      this.app.log.info('DEV LOGIN USED');
    }

    return this.issueSession(account, memberships);
  }

  async refresh(
    refreshToken: string,
    businessId?: string,
  ): Promise<AuthSessionResponse> {
    this.ensureAuthSecrets();

    const tokenHash = hashToken(refreshToken);
    const stored = await this.repository.findRefreshTokenByHash(tokenHash);

    if (!stored) {
      throw new AppError('INVALID_TOKEN', 'Invalid refresh token', 401);
    }

    if (stored.expiresAt.getTime() < Date.now()) {
      await this.repository.revokeRefreshTokenById(stored.id);
      throw new AppError('TOKEN_EXPIRED', 'Refresh token has expired', 401);
    }

    const accountRow = await this.repository.findAccountById(stored.accountId);
    if (!accountRow) {
      throw new AppError('INVALID_TOKEN', 'Account not found', 401);
    }

    const memberships = await this.repository.findMembershipsByAccountId(
      stored.accountId,
    );

    await this.repository.revokeRefreshTokenById(stored.id);

    if (businessId) {
      const membership = memberships.find((m) => m.businessId === businessId);
      if (!membership) {
        throw new AppError(
          'FORBIDDEN',
          'You do not have access to this business',
          403,
        );
      }

      const newRefreshToken = generateRefreshToken();
      const newRefreshHash = hashToken(newRefreshToken);
      const expiresAt = new Date(Date.now() + REFRESH_TOKEN_TTL_MS);

      await this.repository.createRefreshToken({
        accountId: accountRow.id,
        userId: membership.userId,
        tokenHash: newRefreshHash,
        expiresAt,
      });

      return {
        access_token: this.signAccessToken({
          account_id: accountRow.id,
          phone: accountRow.phone,
          user_id: membership.userId,
          business_id: membership.businessId,
          role: membership.role,
        }),
        refresh_token: newRefreshToken,
        expires_in: ACCESS_TOKEN_TTL_SECONDS,
        user: buildUserResponse(accountRow, {
          userId: membership.userId,
          role: membership.role,
        }),
        businesses: toBusinessSummaries(memberships),
      };
    }

    return this.issueSession(accountRow, memberships);
  }

  async logout(refreshToken: string): Promise<void> {
    const tokenHash = hashToken(refreshToken);
    await this.repository.revokeRefreshToken(tokenHash);
  }

  async getMe(payload: JwtAccessPayload): Promise<MeResponse> {
    const accountRow = await this.repository.findAccountById(
      payload.account_id,
    );
    if (!accountRow) {
      throw new AppError('NOT_FOUND', 'Account not found', 404);
    }

    const memberships = await this.repository.findMembershipsByAccountId(
      payload.account_id,
    );
    const businesses = toBusinessSummaries(memberships);

    let selectedBusiness: BusinessSummaryResponse | null = null;
    let user = buildUserResponse(accountRow);

    if (payload.business_id && payload.user_id) {
      const membership = memberships.find(
        (m) => m.businessId === payload.business_id,
      );
      if (membership) {
        selectedBusiness =
          businesses.find((b) => b.id === membership.businessId) ?? null;
        user = buildUserResponse(accountRow, {
          userId: membership.userId,
          role: membership.role,
        });
      }
    }

    return {
      user,
      businesses,
      selected_business: selectedBusiness,
      profile: {
        ...buildProfileResponse(accountRow),
        avatar_url: await new AccountAvatarService({
          config: this.config,
          authRepository: this.repository,
        }).resolveAvatarUrl(
          accountRow.id,
          accountRow.avatarMediaAssetId,
          accountRow.avatarUrl,
        ),
      },
    };
  }
}
