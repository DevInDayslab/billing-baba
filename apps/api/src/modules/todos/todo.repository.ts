import { and, count, desc, eq, sql } from 'drizzle-orm';
import type { Database } from '../../db/client';
import { todos } from '../../db/schema/notifications/tables';
import type {
  ListTodosParams,
  TodoInsertValues,
  TodoRecord,
  TodoUpdateValues,
} from './todo.types';

type TodoRow = typeof todos.$inferSelect;

function mapTodoRow(row: TodoRow): TodoRecord {
  return {
    id: row.id,
    businessId: row.businessId,
    title: row.title,
    description: row.description,
    priority: row.priority,
    category: row.category,
    partyId: row.partyId,
    dueDate: row.dueDate,
    reminderAt: row.reminderAt?.toISOString() ?? null,
    isCompleted: row.isCompleted,
    completedAt: row.completedAt?.toISOString() ?? null,
    isPinned: row.isPinned,
    linkedInvoiceId: row.linkedInvoiceId,
    linkedPurchaseId: row.linkedPurchaseId,
    linkedProductId: row.linkedProductId,
    attachmentIds: Array.isArray(row.attachmentIds) ? row.attachmentIds : [],
    syncVersion: row.syncVersion,
    createdAt: row.createdAt.toISOString(),
    updatedAt: row.updatedAt.toISOString(),
  };
}

export class TodoRepository {
  constructor(private readonly db: Database) {}

  async list(params: ListTodosParams): Promise<{
    rows: TodoRecord[];
    total: number;
  }> {
    const conditions = [
      eq(todos.businessId, params.businessId),
      eq(todos.isDeleted, false),
    ];

    if (params.isCompleted !== undefined) {
      conditions.push(eq(todos.isCompleted, params.isCompleted));
    }

    const whereClause = and(...conditions);
    const [totalRow] = await this.db
      .select({ total: count() })
      .from(todos)
      .where(whereClause);

    const offset = (params.page - 1) * params.limit;
    const rows = await this.db
      .select()
      .from(todos)
      .where(whereClause)
      .orderBy(desc(todos.isPinned), desc(todos.updatedAt))
      .limit(params.limit)
      .offset(offset);

    return {
      rows: rows.map(mapTodoRow),
      total: Number(totalRow?.total ?? 0),
    };
  }

  async findById(
    businessId: string,
    todoId: string,
  ): Promise<TodoRecord | null> {
    const [row] = await this.db
      .select()
      .from(todos)
      .where(
        and(
          eq(todos.businessId, businessId),
          eq(todos.id, todoId),
          eq(todos.isDeleted, false),
        ),
      )
      .limit(1);

    return row ? mapTodoRow(row) : null;
  }

  async create(values: TodoInsertValues): Promise<TodoRecord> {
    const [row] = await this.db
      .insert(todos)
      .values({
        id: values.id,
        businessId: values.businessId,
        title: values.title,
        description: values.description ?? null,
        priority: values.priority ?? 'medium',
        category: values.category ?? null,
        partyId: values.partyId ?? null,
        dueDate: values.dueDate ?? null,
        reminderAt: values.reminderAt ?? null,
        isCompleted: values.isCompleted ?? false,
        completedAt: values.completedAt ?? null,
        isPinned: values.isPinned ?? false,
        linkedInvoiceId: values.linkedInvoiceId ?? null,
        linkedPurchaseId: values.linkedPurchaseId ?? null,
        linkedProductId: values.linkedProductId ?? null,
        attachmentIds: values.attachmentIds ?? [],
        deviceId: values.deviceId ?? null,
      })
      .returning();

    if (!row) {
      throw new Error('Failed to create todo');
    }

    return mapTodoRow(row);
  }

  async update(
    businessId: string,
    todoId: string,
    values: TodoUpdateValues,
  ): Promise<TodoRecord | null> {
    const [row] = await this.db
      .update(todos)
      .set({
        ...(values.title !== undefined ? { title: values.title } : {}),
        ...(values.description !== undefined
          ? { description: values.description }
          : {}),
        ...(values.priority !== undefined ? { priority: values.priority } : {}),
        ...(values.category !== undefined ? { category: values.category } : {}),
        ...(values.partyId !== undefined ? { partyId: values.partyId } : {}),
        ...(values.dueDate !== undefined ? { dueDate: values.dueDate } : {}),
        ...(values.reminderAt !== undefined
          ? { reminderAt: values.reminderAt }
          : {}),
        ...(values.isCompleted !== undefined
          ? { isCompleted: values.isCompleted }
          : {}),
        ...(values.completedAt !== undefined
          ? { completedAt: values.completedAt }
          : {}),
        ...(values.isPinned !== undefined ? { isPinned: values.isPinned } : {}),
        ...(values.linkedInvoiceId !== undefined
          ? { linkedInvoiceId: values.linkedInvoiceId }
          : {}),
        ...(values.linkedPurchaseId !== undefined
          ? { linkedPurchaseId: values.linkedPurchaseId }
          : {}),
        ...(values.linkedProductId !== undefined
          ? { linkedProductId: values.linkedProductId }
          : {}),
        ...(values.attachmentIds !== undefined
          ? { attachmentIds: values.attachmentIds }
          : {}),
        updatedAt: sql`now()`,
        syncVersion: sql`${todos.syncVersion} + 1`,
      })
      .where(
        and(
          eq(todos.businessId, businessId),
          eq(todos.id, todoId),
          eq(todos.isDeleted, false),
        ),
      )
      .returning();

    return row ? mapTodoRow(row) : null;
  }

  async softDelete(businessId: string, todoId: string): Promise<boolean> {
    const [row] = await this.db
      .update(todos)
      .set({
        isDeleted: true,
        deletedAt: sql`now()`,
        updatedAt: sql`now()`,
        syncVersion: sql`${todos.syncVersion} + 1`,
      })
      .where(
        and(
          eq(todos.businessId, businessId),
          eq(todos.id, todoId),
          eq(todos.isDeleted, false),
        ),
      )
      .returning({ id: todos.id });

    return Boolean(row);
  }
}
