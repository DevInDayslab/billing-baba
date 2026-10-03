import { describe, expect, test } from 'bun:test';
import { assertCollaborationAction } from '../../../src/modules/collaboration/collaboration.permissions';
import { AppError } from '../../../src/shared/errors/app-error';

describe('collaboration permissions', () => {
  test('allows owners for member management actions', () => {
    expect(() =>
      assertCollaborationAction(true, 'members:update'),
    ).not.toThrow();
    expect(() =>
      assertCollaborationAction(true, 'members:delete'),
    ).not.toThrow();
    expect(() => assertCollaborationAction(true, 'members:read')).not.toThrow();
  });

  test('blocks collaborators from member management mutations', () => {
    expect(() =>
      assertCollaborationAction(false, 'members:update', 'biller'),
    ).toThrow(AppError);
    expect(() =>
      assertCollaborationAction(false, 'members:delete', 'biller'),
    ).toThrow(AppError);
    expect(() =>
      assertCollaborationAction(false, 'members:read', 'biller'),
    ).toThrow(AppError);
  });
});
