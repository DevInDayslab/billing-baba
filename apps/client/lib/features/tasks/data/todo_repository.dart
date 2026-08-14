import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class TodoDto {
  const TodoDto({
    required this.id,
    required this.title,
    required this.createdAt, required this.updatedAt, this.description,
    this.priority = 'medium',
    this.category,
    this.partyId,
    this.dueDate,
    this.reminderAt,
    this.isCompleted = false,
    this.completedAt,
    this.isPinned = false,
    this.linkedInvoiceId,
    this.linkedPurchaseId,
    this.linkedProductId,
    this.attachmentIds = const [],
    this.syncVersion = 1,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(String? value) =>
        value == null || value.isEmpty ? null : DateTime.tryParse(value);

    return TodoDto(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: json['priority'] as String? ?? 'medium',
      category: json['category'] as String?,
      partyId: json['party_id'] as String?,
      dueDate: json['due_date'] as String?,
      reminderAt: parseDate(json['reminder_at'] as String?),
      isCompleted: json['is_completed'] as bool? ?? false,
      completedAt: parseDate(json['completed_at'] as String?),
      isPinned: json['is_pinned'] as bool? ?? false,
      linkedInvoiceId: json['linked_invoice_id'] as String?,
      linkedPurchaseId: json['linked_purchase_id'] as String?,
      linkedProductId: json['linked_product_id'] as String?,
      attachmentIds:
          (json['attachment_ids'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      syncVersion: json['sync_version'] as int? ?? 1,
      createdAt:
          parseDate(json['created_at'] as String?) ?? DateTime.now().toUtc(),
      updatedAt:
          parseDate(json['updated_at'] as String?) ?? DateTime.now().toUtc(),
    );
  }

  final String id;
  final String title;
  final String? description;
  final String priority;
  final String? category;
  final String? partyId;
  final String? dueDate;
  final DateTime? reminderAt;
  final bool isCompleted;
  final DateTime? completedAt;
  final bool isPinned;
  final String? linkedInvoiceId;
  final String? linkedPurchaseId;
  final String? linkedProductId;
  final List<String> attachmentIds;
  final int syncVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// REST hydration for dashboard todos when local Drift is empty.
class TodoRepository {
  TodoRepository(this._dio);

  final Dio _dio;

  Future<List<TodoDto>> listTodos({int limit = 200}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.todos,
      queryParameters: {'limit': limit},
    );
    final data = response.data?['data'];
    if (data is! List) return const [];
    return data
        .whereType<Map<Object?, Object?>>()
        .map((e) => TodoDto.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
