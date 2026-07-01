import { relations } from 'drizzle-orm';
import { businesses } from '../business/tables';
import {
  accounts,
  attendanceRecords,
  devices,
  refreshTokens,
  users,
} from './tables';

export const accountsRelations = relations(accounts, ({ many }) => ({
  users: many(users),
  refreshTokens: many(refreshTokens),
}));

export const usersRelations = relations(users, ({ one, many }) => ({
  account: one(accounts, {
    fields: [users.accountId],
    references: [accounts.id],
  }),
  business: one(businesses, {
    fields: [users.businessId],
    references: [businesses.id],
  }),
  refreshTokens: many(refreshTokens),
  attendanceRecords: many(attendanceRecords),
  devices: many(devices),
}));

export const devicesRelations = relations(devices, ({ one }) => ({
  business: one(businesses, {
    fields: [devices.businessId],
    references: [businesses.id],
  }),
  user: one(users, {
    fields: [devices.userId],
    references: [users.id],
  }),
}));

export const refreshTokensRelations = relations(refreshTokens, ({ one }) => ({
  account: one(accounts, {
    fields: [refreshTokens.accountId],
    references: [accounts.id],
  }),
  user: one(users, {
    fields: [refreshTokens.userId],
    references: [users.id],
  }),
}));

export const attendanceRecordsRelations = relations(
  attendanceRecords,
  ({ one }) => ({
    business: one(businesses, {
      fields: [attendanceRecords.businessId],
      references: [businesses.id],
    }),
    user: one(users, {
      fields: [attendanceRecords.userId],
      references: [users.id],
    }),
  }),
);
