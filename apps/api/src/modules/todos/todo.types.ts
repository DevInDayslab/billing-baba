export type TodoRecord = {
  id: string;
  businessId: string;
  title: string;
  description: string | null;
  priority: 'low' | 'medium' | 'high';
  category: string | null;
  partyId: string | null;
  dueDate: string | null;
  reminderAt: string | null;
  isCompleted: boolean;
  completedAt: string | null;
  isPinned: boolean;
  linkedInvoiceId: string | null;
  linkedPurchaseId: string | null;
  linkedProductId: string | null;
  attachmentIds: string[];
  syncVersion: number;
  createdAt: string;
  updatedAt: string;
};

export type ListTodosParams = {
  businessId: string;
  page: number;
  limit: number;
  isCompleted?: boolean;
};

export type TodoInsertValues = {
  id?: string;
  businessId: string;
  title: string;
  description?: string | null;
  priority?: 'low' | 'medium' | 'high';
  category?: string | null;
  partyId?: string | null;
  dueDate?: string | null;
  reminderAt?: Date | null;
  isCompleted?: boolean;
  completedAt?: Date | null;
  isPinned?: boolean;
  linkedInvoiceId?: string | null;
  linkedPurchaseId?: string | null;
  linkedProductId?: string | null;
  attachmentIds?: string[];
  deviceId?: string | null;
};

export type TodoUpdateValues = Partial<
  Omit<TodoInsertValues, 'businessId' | 'id'>
>;
