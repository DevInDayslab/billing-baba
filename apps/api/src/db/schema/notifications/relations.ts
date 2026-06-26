import { relations } from 'drizzle-orm';
import { parties } from '../crm/tables';
import { alerts, todos } from './tables';

export const alertsRelations = relations(alerts, () => ({}));

export const todosRelations = relations(todos, ({ one }) => ({
  party: one(parties, {
    fields: [todos.partyId],
    references: [parties.id],
  }),
}));
