import { z } from 'zod';

export const todoIdParamSchema = z.object({
  id: z.string().uuid(),
});

export const listTodosQuerySchema = z.object({
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(200).default(50),
  is_completed: z
    .enum(['true', 'false'])
    .optional()
    .transform((value) =>
      value === undefined ? undefined : value === 'true',
    ),
});

export const createTodoBodySchema = z.object({
  title: z.string().trim().min(1).max(500),
  description: z.string().trim().max(5000).optional().nullable(),
  priority: z.enum(['low', 'medium', 'high']).optional(),
  category: z.string().trim().max(100).optional().nullable(),
  party_id: z.string().uuid().optional().nullable(),
  due_date: z.string().date().optional().nullable(),
  reminder_at: z.string().datetime().optional().nullable(),
  is_pinned: z.boolean().optional(),
  linked_invoice_id: z.string().uuid().optional().nullable(),
  linked_purchase_id: z.string().uuid().optional().nullable(),
  linked_product_id: z.string().uuid().optional().nullable(),
  attachment_ids: z.array(z.string()).optional(),
});

export const updateTodoBodySchema = createTodoBodySchema
  .partial()
  .extend({
    is_completed: z.boolean().optional(),
    completed_at: z.string().datetime().optional().nullable(),
  });

export type CreateTodoBody = z.infer<typeof createTodoBodySchema>;
export type UpdateTodoBody = z.infer<typeof updateTodoBodySchema>;
export type ListTodosQuery = z.infer<typeof listTodosQuerySchema>;
