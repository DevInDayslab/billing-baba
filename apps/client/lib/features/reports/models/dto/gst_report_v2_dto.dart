class GstReportWarningDto {
  const GstReportWarningDto({
    required this.code,
    required this.message,
    required this.count,
    this.documentIds = const [],
  });

  factory GstReportWarningDto.fromJson(Map<String, dynamic> json) {
    final ids = json['document_ids'];
    return GstReportWarningDto(
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      documentIds: ids is List ? ids.map((e) => e.toString()).toList() : const [],
    );
  }

  final String code;
  final String message;
  final int count;
  final List<String> documentIds;
}

class GstReportSectionDto {
  const GstReportSectionDto({
    required this.key,
    required this.title,
    required this.rows,
    this.totals = const {},
  });

  factory GstReportSectionDto.fromJson(Map<String, dynamic> json) {
    final rowsJson = json['rows'];
    final totalsJson = json['totals'];
    return GstReportSectionDto(
      key: json['key'] as String? ?? '',
      title: json['title'] as String? ?? '',
      rows: rowsJson is List
          ? rowsJson
                .whereType<Map<String, dynamic>>()
                .map((row) => Map<String, dynamic>.from(row))
                .toList()
          : const [],
      totals: totalsJson is Map
          ? totalsJson.map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
    );
  }

  final String key;
  final String title;
  final List<Map<String, dynamic>> rows;
  final Map<String, String> totals;
}

class GstReportEnvelopeDto {
  const GstReportEnvelopeDto({
    required this.meta,
    required this.sections,
    required this.totals,
    required this.warnings,
  });

  factory GstReportEnvelopeDto.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'];
    final warningsJson = json['warnings'];
    final totalsJson = json['totals'];
    return GstReportEnvelopeDto(
      meta: Map<String, dynamic>.from(
        (json['meta'] as Map<String, dynamic>?) ?? {},
      ),
      sections: sectionsJson is List
          ? sectionsJson
                .whereType<Map<String, dynamic>>()
                .map(GstReportSectionDto.fromJson)
                .toList()
          : const [],
      totals: totalsJson is Map
          ? totalsJson.map((k, v) => MapEntry(k.toString(), v.toString()))
          : const {},
      warnings: warningsJson is List
          ? warningsJson
                .whereType<Map<String, dynamic>>()
                .map(GstReportWarningDto.fromJson)
                .toList()
          : const [],
    );
  }

  final Map<String, dynamic> meta;
  final List<GstReportSectionDto> sections;
  final Map<String, String> totals;
  final List<GstReportWarningDto> warnings;
}
