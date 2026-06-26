import { relations } from 'drizzle-orm';
import {
  attendanceRecords,
  devices,
  refreshTokens,
  users,
} from './tables';
import { businesses } from '../business/tables';

export const usersRelations = relations(users, ({ one, many }) => ({
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
  user: one(users, {
    fields: [refreshTokens.userId],
    references: [users.id],
  }),
}));

export const attendanceRecordsRelations = relations(attendanceRecords, ({ one }) => ({
  business: one(businesses, {
    fields: [attendanceRecords.businessId],
    references: [businesses.id],
  }),
  user: one(users, {
    fields: [attendanceRecords.userId],
    references: [users.id],
  }),
}));
