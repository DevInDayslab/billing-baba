import { and, eq } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { companyMembers } from '../../db/schema/collaboration/tables';
import { users } from '../../db/schema/identity/tables';
import type { UserRole } from '../../modules/auth/auth.types';
import type { CollaborationRole } from '../../modules/collaboration/collaboration.types';
import { AppError } from '../errors/app-error';
import type {
  BusinessAccessContext,
  PermissionAction,
  PermissionModule,
} from './collaboration-permission.types';
import { canPermission, presetDto } from './role-permission-registry';

export class BusinessAccessService {
  constructor(private readonly db: Database) {}

  async resolve(
    accountId: string,
    businessId: string,
    userRole?: UserRole,
  ): Promise<BusinessAccessContext> {
    if (userRole === 'owner' || userRole === 'manager') {
      return { kind: 'full' };
    }

    const [member] = await this.db
      .select({ role: companyMembers.role })
      .from(companyMembers)
      .where(
        and(
          eq(companyMembers.companyId, businessId),
          eq(companyMembers.accountId, accountId),
          eq(companyMembers.status, 'active'),
        ),
      )
      .limit(1);

    if (member) {
      return { kind: 'collaborator', role: member.role as CollaborationRole };
    }

    const [staffUser] = await this.db
      .select({ id: users.id })
      .from(users)
      .where(
        and(
          eq(users.businessId, businessId),
          eq(users.accountId, accountId),
          eq(users.isActive, true),
          eq(users.isDeleted, false),
        ),
      )
      .limit(1);

    if (staffUser) {
      return { kind: 'full' };
    }

    throw new AppError(
      'FORBIDDEN',
      'You do not have access to this business',
      403,
    );
  }

  can(
    access: BusinessAccessContext,
    module: PermissionModule,
    action: PermissionAction,
  ): boolean {
    return canPermission(access, module, action);
  }

  assert(
    access: BusinessAccessContext,
    module: PermissionModule,
    action: PermissionAction,
    message = 'Your role does not allow this action',
  ): void {
    if (!this.can(access, module, action)) {
      throw new AppError('FORBIDDEN', message, 403);
    }
  }

  currentPreset(access: BusinessAccessContext) {
    if (access.kind === 'full') {
      return null;
    }
    return presetDto(access.role);
  }
}
