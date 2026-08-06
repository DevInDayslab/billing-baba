import { randomUUID } from 'node:crypto';
import { getDb } from '../../db/client';
import { AppError } from '../../shared/errors/app-error';
import { TodoRepository } from './todo.repository';
import type { CreateTodoBody, ListTodosQuery, UpdateTodoBody } from './todo.schema';
import type { TodoRecord } from './todo.types';

export class TodoService {
  private readonly repository: TodoRepository;

  constructor() {
    const db = getDb();
    if (!db) {
      throw new AppError(
        'DATABASE_NOT_CONFIGURED',
        'Database is not configured',
        503,
      );
    }
    this.repository = new TodoRepository(db);
  }

  async list(businessId: string, query: ListTodosQuery) {
    const result = await this.repository.list({
      businessId,
      page: query.page,
      limit: query.limit,
      isCompleted: query.is_completed,
    });

    return {
      data: result.rows,
      meta: {
        page: query.page,
        limit: query.limit,
        total: result.total,
      },
    };
  }

  async getById(businessId: string, todoId: string): Promise<TodoRecord> {
    const row = await this.repository.findById(businessId, todoId);
    if (!row) {
      throw new AppError('NOT_FOUND', 'Todo not found', 404);
    }
    return row;
  }

  async create(businessId: string, body: CreateTodoBody): Promise<TodoRecord> {
    return this.repository.create({
      id: randomUUID(),
      businessId,
      title: body.title,
      description: body.description ?? null,
      priority: body.priority,
      category: body.category ?? null,
      partyId: body.party_id ?? null,
      dueDate: body.due_date ?? null,
      reminderAt: body.reminder_at ? new Date(body.reminder_at) : null,
      isPinned: body.is_pinned ?? false,
      linkedInvoiceId: body.linked_invoice_id ?? null,
      linkedPurchaseId: body.linked_purchase_id ?? null,
      linkedProductId: body.linked_product_id ?? null,
      attachmentIds: body.attachment_ids ?? [],
    });
  }

  async update(
    businessId: string,
    todoId: string,
    body: UpdateTodoBody,
  ): Promise<TodoRecord> {
    const existing = await this.repository.findById(businessId, todoId);
    if (!existing) {
      throw new AppError('NOT_FOUND', 'Todo not found', 404);
    }

    const completedAt =
      body.completed_at === undefined
        ? body.is_completed === true
          ? new Date()
          : body.is_completed === false
            ? null
            : undefined
        : body.completed_at
          ? new Date(body.completed_at)
          : null;

    const updated = await this.repository.update(businessId, todoId, {
      title: body.title,
      description: body.description,
      priority: body.priority,
      category: body.category,
      partyId: body.party_id,
      dueDate: body.due_date,
      reminderAt:
        body.reminder_at === undefined
          ? undefined
          : body.reminder_at
            ? new Date(body.reminder_at)
            : null,
      isCompleted: body.is_completed,
      completedAt,
      isPinned: body.is_pinned,
      linkedInvoiceId: body.linked_invoice_id,
      linkedPurchaseId: body.linked_purchase_id,
      linkedProductId: body.linked_product_id,
      attachmentIds: body.attachment_ids,
    });

    if (!updated) {
      throw new AppError('NOT_FOUND', 'Todo not found', 404);
    }

    return updated;
  }

  async delete(businessId: string, todoId: string): Promise<void> {
    const deleted = await this.repository.softDelete(businessId, todoId);
    if (!deleted) {
      throw new AppError('NOT_FOUND', 'Todo not found', 404);
    }
  }
}
