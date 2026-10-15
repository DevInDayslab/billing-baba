class PartyContactImportSessionCreated {
  const PartyContactImportSessionCreated({
    required this.sessionId,
    required this.token,
    required this.webUrl,
    required this.deepLinkUrl,
    required this.qrDataUrl,
    required this.expiresAt,
    required this.notificationSent,
  });

  factory PartyContactImportSessionCreated.fromJson(Map<String, dynamic> json) {
    return PartyContactImportSessionCreated(
      sessionId: json['session_id'] as String,
      token: json['token'] as String,
      webUrl: json['web_url'] as String,
      deepLinkUrl: json['deep_link_url'] as String,
      qrDataUrl: json['qr_data_url'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      notificationSent: json['notification_sent'] as bool? ?? false,
    );
  }

  final String sessionId;
  final String token;
  final String webUrl;
  final String deepLinkUrl;
  final String qrDataUrl;
  final DateTime expiresAt;
  final bool notificationSent;
}

class PartyContactImportStagingRowDto {
  const PartyContactImportStagingRowDto({
    required this.displayName,
    required this.primaryPhone,
    required this.phones,
    this.email,
    this.address,
    required this.sortOrder,
  });

  factory PartyContactImportStagingRowDto.fromJson(Map<String, dynamic> json) {
    return PartyContactImportStagingRowDto(
      displayName: json['display_name'] as String,
      primaryPhone: json['primary_phone'] as String,
      phones: (json['phones'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      email: json['email'] as String?,
      address: json['address'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'display_name': displayName,
    'phones': phones,
    if (email != null && email!.isNotEmpty) 'email': email,
    if (address != null && address!.isNotEmpty) 'address': address,
  };

  final String displayName;
  final String primaryPhone;
  final List<String> phones;
  final String? email;
  final String? address;
  final int sortOrder;
}

class PartyContactImportSession {
  const PartyContactImportSession({
    required this.id,
    required this.businessId,
    required this.status,
    required this.expiresAt,
    required this.stagingCount,
    this.stagingRows = const [],
    this.companyName,
  });

  factory PartyContactImportSession.fromJson(Map<String, dynamic> json) {
    final rows = json['staging_rows'];
    return PartyContactImportSession(
      id: json['id'] as String,
      businessId: json['business_id'] as String,
      status: json['status'] as String,
      expiresAt: DateTime.parse(json['expires_at'] as String),
      stagingCount: json['staging_count'] as int? ?? 0,
      companyName: json['company_name'] as String?,
      stagingRows: rows is List
          ? rows
                .whereType<Map<String, dynamic>>()
                .map(PartyContactImportStagingRowDto.fromJson)
                .toList()
          : const [],
    );
  }

  final String id;
  final String businessId;
  final String status;
  final DateTime expiresAt;
  final int stagingCount;
  final List<PartyContactImportStagingRowDto> stagingRows;
  final String? companyName;
}
