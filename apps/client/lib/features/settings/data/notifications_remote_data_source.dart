import 'package:billing_baba/core/network/api_endpoints.dart';
import 'package:dio/dio.dart';

class NotifyDispatchResult {
  const NotifyDispatchResult({
    required this.notified,
    this.deduped = false,
    this.shareUrl,
    this.token,
    this.mediaAttached = false,
    this.errorCode,
    this.errorMessage,
  });

  factory NotifyDispatchResult.fromJson(Map<String, dynamic> json) {
    final error = json['error'] as Map<String, dynamic>?;
    return NotifyDispatchResult(
      notified: json['notified'] as bool? ?? false,
      deduped: json['deduped'] as bool? ?? false,
      shareUrl: json['share_url'] as String?,
      token: json['token'] as String?,
      mediaAttached: json['media_attached'] as bool? ?? false,
      errorCode: error?['code'] as String?,
      errorMessage: error?['message'] as String?,
    );
  }

  final bool notified;
  final bool deduped;
  final String? shareUrl;
  final String? token;
  final bool mediaAttached;
  final String? errorCode;
  final String? errorMessage;
}

class NotificationStatusDto {
  const NotificationStatusDto({
    required this.provider,
    required this.connected,
    this.senderMasked,
    this.websiteUrl,
  });

  factory NotificationStatusDto.fromJson(Map<String, dynamic> json) {
    return NotificationStatusDto(
      provider: json['provider'] as String? ?? 'console',
      connected: json['connected'] as bool? ?? false,
      senderMasked: json['sender_masked'] as String?,
      websiteUrl: json['website_url'] as String?,
    );
  }

  final String provider;
  final bool connected;
  final String? senderMasked;
  final String? websiteUrl;
}

class NotificationsRemoteDataSource {
  NotificationsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<NotificationStatusDto> getStatus() async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.notificationsStatus,
    );
    return NotificationStatusDto.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<NotifyDispatchResult> sendTest(String phone) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.notificationsTest,
      data: {'phone': phone},
    );
    return NotifyDispatchResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<NotifyDispatchResult> sendPartyReminder({
    required String partyId,
    String? phone,
    String? dueDate,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.partyReminders(partyId),
      data: {
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (dueDate != null && dueDate.isNotEmpty) 'due_date': dueDate,
      },
    );
    return NotifyDispatchResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<NotifyDispatchResult> shareSalesDocument(String id) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentShare(id),
    );
    return NotifyDispatchResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<NotifyDispatchResult> notifySalesDocument(
    String id, {
    String? phone,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.salesDocumentNotify(id),
      data: {
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      },
    );
    return NotifyDispatchResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }

  Future<NotifyDispatchResult> notifyPaymentReceived(String paymentId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiEndpoints.paymentNotify(paymentId),
    );
    return NotifyDispatchResult.fromJson(
      (response.data?['data'] as Map<String, dynamic>?) ?? {},
    );
  }
}
